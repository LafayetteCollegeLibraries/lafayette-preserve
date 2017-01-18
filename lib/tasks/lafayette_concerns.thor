# -*- coding: utf-8 -*-

require 'thor/rails'
require 'pg'
require_relative '../metadb-api/metadb'
require 'bagit'
require 'zip'
require 'csv'

class Metadb < Thor
  include Thor::Rails

  desc "upload_vocabulary", "import a Project from MetaDB"

  option :vocab_file_path, :aliases => "-V", :desc => "Path to the exported vocabulary file", :required => true
  option :publisher, :aliases => "-p", :desc => "Publisher for the vocabulary"
  def upload_vocabulary

    user = User.find_by(email: 'griffinj@lafayette.edu')

    vocab_values = CSV.read(options[:vocab_file_path])

    title = vocab_values[1][0]

    slug = title.downcase.gsub(/\./,'-')

    vocab_uri = "http://authority.lafayette.edu/ns/#{slug}"

    vocab = Vocabulary.new(vocab_uri)
    vocab.title << title
    vocab.label = vocab.title
    vocab.pref_label = vocab.label
    vocab.publisher << options[:publisher] if options.has_key? :publisher

    vocab.children.each do |child|
      child.destroy
    end

    vocab.persist!

    vocab_values[1..-1].each do |term_value|

      label = term_value[1]

      term_slug = label.gsub(' ', '-').gsub(/[[:punct:]]/, '')
      term_iri = Addressable::URI.parse("#{vocab_uri}##{term_slug}")
      term_uri = term_iri.normalize

      term = Term.new(term_uri)
      term.label << label
      term.pref_label << label

#      puts term.label
      term.persist!
    end
  end

  desc "ingest_bag", "ingest a ZIP-compressed Bag"
  option :bag, :aliases => "-b", :desc => "ZIP-compressed Bag", :required => true
  option :private, :aliases => "-p", :desc => "privately accessible", :type => :boolean, :default => false
  def ingest_bag

    user = User.find_by(email: 'griffinj@lafayette.edu')

    item_name = options[:bag].split('/').last.gsub(/\.zip/, '')

    Zip::File.open(options[:bag]) do |zip_file|

      # Handle entries one by one
      zip_file.each do |entry|

        # Extract to file/directory/symlink
        puts "Extracting #{entry.name}"
        if not File.exists? entry.name
          entry.extract(entry.name)
        
          # Read into memory
          unless File.directory? entry.name
            File.open(entry.name, 'wb') { |file| file.write(entry.get_input_stream.read) } 
          end
        end
      end
    end

    # Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)

    ### Create the CurationConcern Work
    curation_concern = GenericWork.new

    ## BaseActor#apply_creation_data_to_curation_concern
    curation_concern.apply_depositor_metadata(user.user_key)
    curation_concern.date_uploaded = CurationConcerns::TimeService.time_in_utc

    ## BaseActor#apply_save_data_to_curation_concern
    curation_concern.date_modified = CurationConcerns::TimeService.time_in_utc

    puts "data/#{item_name}_metadata.csv"

    imported_metadata = CSV.read("data/#{item_name}_metadata.csv")
    imported_attributes = {}

    imported_metadata.each do |record|

      case record[0]
        
      when 'title'
        case record[1]
        when 'english'
          attr_key = :title
        when 'japanese'
          attr_key = :title_japanese
        when 'chinese'
          attr_key = :title_chinese
        when 'korean'
          attr_key = :title_korean
        else
          attr_key = :title
        end

      when 'contributor'
        attr_key = :contributor
      when 'coverage'
        case record[1]
        when 'location'
          attr_key = :coverage_location
        when 'location.country'
          attr_key = :coverage_location_country
        end

      when 'creator'
        case record[1]
        when 'company'
          attr_key = :creator_company
        when 'digital'
          attr_key = :creator_digital
        when 'maker'
          attr_key = :creator_maker
        else
          attr_key = :creator
        end

      when 'date'
        case record[1]
        when 'image.lower'
          attr_key = :date_image_lower
        when 'image.upper'
          attr_key = :date_image_upper
        when 'artifact.lower'
          attr_key = :date_artifact_lower
        when 'artifact.upper'
          attr_key = :date_artifact_upper
        when 'original'
          attr_key = :date_original
        end
      when 'description'
        case record[1]
        when 'citation'
          attr_key = :description_citation
        when 'critical'
          attr_key = :description_critical
        when 'ethnicity'
          attr_key = :description_ethnicity
        when 'indicia'
          attr_key = :description_indicia
        when 'inscription.english'
          attr_key = :description_inscription
        when 'inscription.japanese'
          attr_key = :description_inscription
        when 'text.english'
          attr_key = :description
        when 'text.japanese'
          attr_key = :description
        when 'condition'
          attr_key = :description_condition
        when 'note'
          attr_key = :description_note
        when 'provenance'
          attr_key = :description_provenance
        when 'series'
          attr_key = :description_series
        else
          attr_key = :description
        end
      when 'format'
        case record[1]
        when 'digital'
          attr_key = :format_digital
        when 'extent'
          attr_key = :format_extent
        when 'medium'
          attr_key = :format_medium
        end
      when 'publisher'
        case record[1]
        when 'digital'
          attr_key = :publisher_digital
        when 'original'
          attr_key = :publisher_original
        end
      when 'rights'
        case record[1]
        when 'digital'
          attr_key = :rights_digital
        end
      when 'subject'
        case record[1]
        when 'ocm'
          attr_key = :subject_ocm
        else
          attr_key = :subject
        end
      when 'source'
        attr_key = :source
      when 'identifier'
        case record[1]
        when 'itemnumber'
          attr_key = :identifier_itemnumber
        end

      end

      if not attr_key.nil?
        imported_attributes[attr_key] = [] unless imported_attributes.has_key? attr_key

        if not record[2].nil? and not record[2].empty?
          record[2].split(';').each do |record_value|
            imported_attributes[attr_key] << record_value
          end
        end
      end
    end

    curation_concern.attributes = imported_attributes

    ### Add the file to a new FileSet
    ## AttachFilesActor#attach_file

    if options[:private]
      curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    else
      curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
    
    files = []
    file_sets = []

    tif_image_path = "data/#{item_name}.tif"
    pdf_doc_path = "data/#{item_name}.pdf"

    if File.file?(tif_image_path)

      # Ensure that the last layer is used for the derivative
      `/usr/bin/env convert data/#{item_name}.tif[0] data/#{item_name}_0.tif`
      front_file = File.new("data/#{item_name}_0.tif", 'rb')
    elsif File.file?(pdf_doc_path)

      front_file = File.new(pdf_doc_path, 'rb')
    end

    files << front_file

    back_files = Dir.glob("data/#{item_name}b*")
    unless back_files.empty?
      back_file_path = back_files.first
      back_file_name = back_file_path.gsub(/\..+$/, '')
      back_file_deriv_path = "#{back_file_name}_0#{File.extname(back_file_path)}"
      `/usr/bin/env convert #{back_file_path}[0] #{back_file_deriv_path}`
      back_file = File.new(back_file_deriv_path, 'rb')
      files << back_file
    end

    relation = :original_file

    files.each do |file|

      file_set = ::FileSet.new
#      curation_concern.ordered_members << file_set
      file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
      file_set_actor.create_metadata(curation_concern)

      # Wrap in an IO decorator to attach passed-in options
      #    local_file = Hydra::Derivatives::IoDecorator.new(File.open(filepath, "rb"))
      local_file = Hydra::Derivatives::IoDecorator.new(file)

      #    local_file.mime_type = opts.fetch(:mime_type, nil)
      local_file.mime_type = nil
      #    local_file.original_name = opts.fetch(:filename, File.basename(filepath))
      local_file.original_name = File.basename(file.to_path)

      puts file_set.id
      puts local_file

      # Tell AddFileToFileSet service to skip versioning because versions will be minted by
      # VersionCommitter when necessary during save_characterize_and_record_committer.
      Hydra::Works::AddFileToFileSet.call(file_set,
                                          local_file,
                                          relation,
                                          versioning: false)

      file_set.save!
      repository_file = file_set.send(relation)

      # Do post file ingest actions
      CurationConcerns::VersioningService.create(repository_file, user)

      path = file.path
      if File.exist?(path)
        filepath = path
      else
        filepath = CurationConcerns::WorkingDirectory.copy_file_to_working_directory(file, file_set.id)
      end

      #    filename = CurationConcerns::WorkingDirectory.find_or_retrieve(repository_file.id, file_set.id, filepath)
      filename = CurationConcerns::WorkingDirectory.find_or_retrieve(repository_file.id, file_set.id)

      raise LoadError, "#{file_set.class.characterization_proxy} was not found" unless file_set.characterization_proxy?
      Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filename)
      # Rails.logger.debug "Ran characterization on #{file_set.characterization_proxy.id} (#{file_set.characterization_proxy.mime_type})"
      file_set.characterization_proxy.save!
      file_set.update_index
      file_set.parent.in_collections.each(&:update_index) if file_set.parent
      
      derivative_url = CurationConcerns::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
      derivative_url = "file://#{derivative_url}"

      Hydra::Derivatives::ImageDerivatives.create(filename,
                                                  outputs: [{ label: :thumbnail, format: 'png', size: '175x175', url: derivative_url }])

      if File.file?(tif_image_path)

        derivative_url = CurationConcerns::DerivativePath.derivative_path_for_reference(file_set, 'jp2')
        #    Hydra::Derivatives::ImageDerivatives.create(filename,
        #                                                outputs: [{ label: :jp2, format: 'jp2', url: derivative_url }])
        `/usr/bin/env convert #{filename} -define numrlvls=7 -define jp2:tilewidth=1024 -define jp2:tileheight=1024 -define jp2:rate=0.02348 -define jp2:prg=rpcl -define jp2:mode=int -define jp2:prcwidth=16383 -define jp2:prcheight=16383 -define jp2:cblkwidth=64 -define jp2:cblkheight=64 -define jp2:sop #{derivative_url}`
      end

      # Reload from Fedora and reindex for thumbnail and extracted text
      file_set.reload
      file_set.update_index
#      file_set.parent.update_index
      
      file_sets << file_set
    end

    ##
    curation_concern.representative = file_sets.first
    curation_concern.thumbnail = file_sets.first
    curation_concern.save!
    puts curation_concern.id
  end
end
