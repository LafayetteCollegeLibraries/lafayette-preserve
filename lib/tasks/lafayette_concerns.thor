# -*- coding: utf-8 -*-

require 'thor/rails'
require 'bagit'
require 'zip'
require 'csv'
require 'metadb'

class Metadb < Thor
  include Thor::Rails

  no_commands do
    def ingest(bag_path, user_email, private_access: false)
      user = User.find_by(email: user_email)
      
      item_name = bag_path.split('/').last.gsub(/\.zip/, '')
      
      Zip::File.open(bag_path) do |zip_file|
        
        # Handle entries one by one
        zip_file.each do |entry|
          
          # Extract to file/directory/symlink
          decompressed_path = ::Rails.root.join('tmp', 'ingest', entry.name)
          entry.extract(decompressed_path)
          
          if not File.exists? decompressed_path
            
            # Read into memory
            unless File.directory? decompressed_path
              
              File.open(decompressed_path, 'wb') { |file| file.write(entry.get_input_stream.read) }
            end
          end
        end
      end
      
      imported_metadata = CSV.read(::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}_metadata.csv"))
      imported_attributes = {}
      imported_metadata.each do |record|
        
        predicate,object = record[0..1]
        attributes = GenericWork.properties.values.select {|value| value.predicate.to_s == predicate }.map {|value| value }
        
        attributes.each do |attribute|
          if attribute.multiple?
            imported_attributes[attribute.term.to_sym] = object.split(';')
          else
            imported_attributes[attribute.term.to_sym] = object.split(';').first
          end
        end
      end
      
      ### Create the CurationConcern Work
      curation_concern = GenericWork.new
      
      ## BaseActor#apply_creation_data_to_curation_concern
      curation_concern.apply_depositor_metadata(user.user_key)
      curation_concern.date_uploaded = CurationConcerns::TimeService.time_in_utc
      
      ## BaseActor#apply_save_data_to_curation_concern
      curation_concern.date_modified = CurationConcerns::TimeService.time_in_utc
      
      ### Add the file to a new FileSet
      ## AttachFilesActor#attach_file
      if private_access
        curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      else
        curation_concern.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
      
      files = []
      file_sets = []
      
      tif_image_path = ::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}.tif")
      jp2_image_path = ::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}.jp2")
      png_image_path = ::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}.png")
      pdf_doc_path = ::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}.pdf")
      
      if File.file?(tif_image_path)
        file_path = ::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}_0.tif")

        # Ensure that the last layer is used for the derivative
        `/usr/bin/env convert #{tif_image_path}[0] #{file_path}`
        files << File.new(file_path, 'rb')
      elsif File.file?(jp2_image_path)
        files << File.new(jp2_image_path, 'rb')
      elsif File.file?(png_image_path)
        files << File.new(png_image_path, 'rb')
      elsif File.file?(pdf_doc_path)
        files << File.new(pdf_doc_path, 'rb')
      end

      imported_attributes[:resource_type] = [ MimeMagic.by_path(files.first.path).type ] unless files.empty?
      curation_concern.attributes = imported_attributes
      
      # Support for customized back ingestion
      back_files = Dir.glob(::Rails.root.join('tmp', 'ingest', 'data', "#{item_name}b*"))
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
        file_set_actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
        file_set_actor.create_metadata(curation_concern)
        
        # Wrap in an IO decorator to attach passed-in options
        local_file = Hydra::Derivatives::IoDecorator.new(file)
        
        local_file.mime_type = nil
        local_file.original_name = File.basename(file.to_path)
        
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

        filename = CurationConcerns::WorkingDirectory.find_or_retrieve(repository_file.id, file_set.id)
        raise LoadError, "#{file_set.class.characterization_proxy} was not found" unless file_set.characterization_proxy?
        Hydra::Works::CharacterizationService.run(file_set.characterization_proxy, filename)

        file_set.characterization_proxy.save!
        file_set.update_index
        file_set.parent.in_collections.each(&:update_index) if file_set.parent
        
        derivative_url = CurationConcerns::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
        derivative_url = "file://#{derivative_url}"
        
        Hydra::Derivatives::ImageDerivatives.create(filename,
                                                    outputs: [{ label: :thumbnail, format: 'png', size: '175x175', url: derivative_url }])
        
        derivative_url = CurationConcerns::DerivativePath.derivative_path_for_reference(file_set, 'jp2')
        #    Hydra::Derivatives::ImageDerivatives.create(filename,
        #                                                outputs: [{ label: :jp2, format: 'jp2', url: derivative_url }])
        `/usr/bin/env convert #{filename} -define numrlvls=7 -define jp2:tilewidth=1024 -define jp2:tileheight=1024 -define jp2:rate=0.02348 -define jp2:prg=rpcl -define jp2:mode=int -define jp2:prcwidth=16383 -define jp2:prcheight=16383 -define jp2:cblkwidth=64 -define jp2:cblkheight=64 -define jp2:sop #{derivative_url}`
        
        # Reload from Fedora and reindex for thumbnail and extracted text
        file_set.reload
        file_set.update_index
        file_sets << file_set
      end
      
      curation_concern.representative = file_sets.first
      curation_concern.thumbnail = file_sets.first
      curation_concern.save!
      
      FileUtils.rm_r Dir.glob(::Rails.root.join('tmp', 'ingest', 'data'))
      FileUtils.rm_r Dir.glob(::Rails.root.join('tmp', 'ingest', '*txt'))
    end
  end

  desc "upload_vocabulary", "import a Project from MetaDB"
  option :user, :aliases => "-u", :desc => "the e-mail address for the user ingesting the Work", :required => true
  option :vocab_file_path, :aliases => "-V", :desc => "Path to the exported vocabulary file", :required => true
  option :publisher, :aliases => "-p", :desc => "Publisher for the vocabulary"
  def upload_vocabulary
    user = User.find_by(email:options[:user])
    vocab_values = CSV.read(options[:vocab_file_path])

    title = vocab_values[1][0]

    slug = title.downcase.gsub(/\./,'-')

    vocab_uri = "http://#{ENV['VOCAB_DOMAIN'] || 'authority.localhost.localdomain'}/ns/#{slug}"

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

      term.persist!
    end
  end

  desc "ingest_bags", "ingest a directory of ZIP-compressed Bags"
  option :bag_dir_path, :aliases => "-d", :desc => "directory of ZIP-compressed Bags", :required => true
  option :private, :aliases => "-p", :desc => "privately accessible", :type => :boolean, :default => false
  option :user, :aliases => "-u", :desc => "the e-mail address for the user ingesting the Work", :required => true
  option :bag_file_attr, :aliases => "-a", :desc => "bag file attribute"
  option :bag_file_attr_eq, :aliases => "-E", :desc => "bag file attribute value"
  option :bag_file_attr_gt, :aliases => "-G", :desc => "bag file attribute condition (greater than)"
  option :bag_file_attr_lt, :aliases => "-L", :desc => "bag file attribute condition (less than)"
  def ingest_bags
    Dir.glob(File.join(options[:bag_dir_path], '*zip')) do |bag_path|

      if options[:bag_file_attr]
        begin
          raise Exception "#{options[:bag_file_attr]} is not a supported file attribute" unless File.stat(bag_path).respond_to?(options[:bag_file_attr].to_sym)
        rescue Exception => e
          $stderr.puts e.msg
        end
        attr_value = File.stat(bag_path).send options[:bag_file_attr].to_sym
        if options[:bag_file_attr_eq]
          bag_file_attr_eq = options[:bag_file_attr_eq]
          bag_file_attr_eq = Time.parse(bag_file_attr_eq) if attr_value.is_a?(Time)

          if attr_value == bag_file_attr_eq
            ingest(bag_path, options[:user], options[:private])
          end
        elsif options[:bag_file_attr_gt]
          bag_file_attr_gt = options[:bag_file_attr_gt]
          bag_file_attr_gt = Time.parse(bag_file_attr_gt) if attr_value.is_a?(Time)

          if attr_value < bag_file_attr_gt
            ingest(bag_path, options[:user], options[:private])
          end
        elsif options[:bag_file_attr_lt]
          bag_file_attr_lt = options[:bag_file_attr_lt]
          bag_file_attr_lt = Time.parse(bag_file_attr_lt) if attr_value.is_a?(Time)

          if attr_value > bag_file_attr_lt
            ingest(bag_path, options[:user], options[:private])
          end
        else
          ingest(bag_path, options[:user], options[:private])
        end
      else
        ingest(bag_path, options[:user], options[:private])
      end
    end
  end

  desc "ingest_bag", "ingest a ZIP-compressed Bag"
  option :bag, :aliases => "-b", :desc => "ZIP-compressed Bag", :required => true
  option :private, :aliases => "-p", :desc => "privately accessible", :type => :boolean, :default => false
  option :user, :aliases => "-u", :desc => "the e-mail address for the user ingesting the Work", :required => true
  def ingest_bag
    ingest(options[:bag], options[:user], private_access: options[:private])
  end
end
