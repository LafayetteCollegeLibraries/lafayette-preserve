# Generated via
#  `rails generate curation_concerns:work GenericWork`

module CurationConcerns
  class GenericWorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = GenericWork
    skip_authorize_resource :only => [ :update, :create ]

    # If any attributes are blank remove them
    # e.g.:
    #   self.attributes = { 'title' => ['first', 'second', ''] }
    #   remove_blank_attributes!
    #   self.attributes
    # => { 'title' => ['first', 'second'] }
    def remove_blank_attributes!(attributes)
      multivalued_form_attributes(attributes).each_with_object(attributes) do |(k, v), h|
        h[k] = v.instance_of?(Array) ? v.select(&:present?) : v
      end
    end

    # Return the hash of attributes that are multivalued and not uploaded files
    def multivalued_form_attributes(attributes)
      attributes.select { |_, v| v.respond_to?(:select) && !v.respond_to?(:read) }
    end

    def update
      respond_to do |wants|
        wants.json do
          # See CurationConcerns::Actors::BaseActor
#          attributes = form_class.model_attributes(params[hash_key_for_curation_concern])
          attributes = params[hash_key_for_curation_concern]
          Rails.logger.warn attributes

          attributes[:rights] = Array(attributes[:rights]) if attributes.key? :rights
          remove_blank_attributes!(attributes)
          curation_concern.attributes = attributes.symbolize_keys
          curation_concern.date_modified = CurationConcerns::TimeService.time_in_utc
          curation_concern.save!
        end
        wants.html do
          super
        end
      end
    end

    # See CurationsConcerns::Actors::ActorStack
    def destroy
      respond_to do |wants|
        wants.json do
          begin
            curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
            curation_concern.destroy
          rescue Ldp::Gone
            render status: 404, layout:'404'
          end
          wants.html do
            super
          end
        end
      end
    end

    def create_work_for_file(zip_file, original_filename)
      item_name = original_filename.gsub(/\..+$/, '')

      tmp_path_base = '/' + File.join('tmp', item_name)
      Dir.mkdir(tmp_path_base) unless File.directory? tmp_path_base

      Zip::File.open(zip_file) do |zip|

        # Handle entries one by one
        zip.each do |entry|

          # Extract to file/directory/symlink
          tmp_entry_path = File.join(tmp_path_base, entry.name)
          if not File.exists?(tmp_entry_path)
            entry.extract(tmp_entry_path)

            # Read into memory
            if entry.name_is_directory?
              Dir.mkdir(tmp_entry_path) unless File.exists?(tmp_entry_path)
            else
              File.open(tmp_entry_path, 'wb') { |file| file.write(entry.get_input_stream.read) }
            end
          end
        end
      end

      ### Create the CurationConcern Work
      user = current_user || ::User.find_by(email: 'griffinj@lafayette.edu')
      work = curation_concern

      ## BaseActor#apply_creation_data_to_curation_concern
      work.apply_depositor_metadata(user.user_key) if user
      work.date_uploaded = CurationConcerns::TimeService.time_in_utc

      ## BaseActor#apply_save_data_to_curation_concern
      work.date_modified = CurationConcerns::TimeService.time_in_utc

      tmp_metadata_path = File.join(tmp_path_base, "data", "#{item_name}_metadata.csv")
      imported_metadata = CSV.read(tmp_metadata_path)
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

      work.attributes = imported_attributes

      ### Add the file to a new FileSet
      ## AttachFilesActor#attach_file

#      if params[:private]
#        work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
#      else
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
#      end
    
      files = []
      file_sets = []
      
      tif_image_path = File.join(tmp_path_base, "data", "#{item_name}.tif")
      pdf_doc_path = File.join(tmp_path_base, "data", "#{item_name}.pdf")
      
      if File.file?(tif_image_path)

        # Ensure that the last layer is used for the derivative
        `/usr/bin/env convert #{tif_image_path}[0] #{tif_image_path}_0.tif`
        front_file = File.new("#{tif_image_path}_0.tif", 'rb')
      elsif File.file?(pdf_doc_path)
        front_file = File.new(pdf_doc_path, 'rb')
      end

      files << front_file
      
      back_files = Dir.glob(File.join(tmp_path_base, 'data', "#{item_name}b*"))

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

        if File.file?(tif_image_path)

          derivative_url = CurationConcerns::DerivativePath.derivative_path_for_reference(file_set, 'jp2')
          #    Hydra::Derivatives::ImageDerivatives.create(filename,
          #                                                outputs: [{ label: :jp2, format: 'jp2', url: derivative_url }])
          `/usr/bin/env convert #{filename} -define numrlvls=7 -define jp2:tilewidth=1024 -define jp2:tileheight=1024 -define jp2:rate=0.02348 -define jp2:prg=rpcl -define jp2:mode=int -define jp2:prcwidth=16383 -define jp2:prcheight=16383 -define jp2:cblkwidth=64 -define jp2:cblkheight=64 -define jp2:sop #{derivative_url}`
        end

        # Reload from Fedora and reindex for thumbnail and extracted text
        file_set.reload
        file_set.update_index
      
        file_sets << file_set
      end

      curation_concern.representative = file_sets.first
      curation_concern.thumbnail = file_sets.first
      curation_concern.save!

      FileUtils.rm zip_file.path if File.exists? zip_file.path
      FileUtils.rm_r tmp_path_base if File.directory? tmp_path_base
    end

    def create
      respond_to do |wants|
        wants.json do
          if params.include? :file

            file_encoded = params[:file]
            file_encoded = file_encoded.gsub(/\s*$/,'')
            original_filename = params[:original_filename]

            m = /data\:(.+?);base64,\s*(.+)/.match file_encoded
            if m
              media_type = m[1]
#              encoded_content = m[2]
              encoded_content = file_encoded.gsub(/data\:.+?;base64,\s*/, '')
              content = Base64.decode64(encoded_content)

              # Create the temporary file
              file = File.open("/tmp/#{original_filename}",'w+b')
              file.write(content)
              if media_type == 'application/zip'

                create_work_for_file(file, original_filename)
              end
              file.close
            end
          end
          render :show, status: :ok
        end
        wants.html do
          super
        end
      end
    end

    # Finds a solr document matching the id and sets @presenter
    # @raises CanCan::AccessDenied if the document is not found
    #   or the user doesn't have access to it.
    def show
      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        wants.json do
          # load and authorize @curation_concern manually because it's skipped for html
          # This has to use #find instead of #load_instance_from_solr because
          # we want to return values like file_set_ids in the json
          @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern

          # Retrieve the Collections
          collections = @curation_concern.part_of.map { |collection_id| ::Collection.find(collection_id) }

          # Retrieve the terms
          @vocabularies = []
          collections.each do |collection|

            collection_vocabs = []
            # @vocabularies += collection.uses_vocabulary.map do |uri|
            collection.uses_vocabulary.map do |uri|
              begin
                collection_vocabs << Vocabulary.find(uri)
              rescue => e
                Rails.logger.warn "Failed to find the Vocabulary resolved using #{uri}: #{e.message}"
              end
            end
            
            @vocabularies += collection_vocabs
          end

          authorize! :show, @curation_concern
          render :show, status: :ok
        end
        additional_response_formats(wants)
        wants.ttl do
          render text: presenter.export_as_ttl
        end
        wants.jsonld do
          render text: presenter.export_as_jsonld
        end
        wants.nt do
          render text: presenter.export_as_nt
        end
      end
    end
  end
end
