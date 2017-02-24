module LafayetteConcerns
  module FileSetsControllerBehavior
    extend ActiveSupport::Concern

    def create_from_upload(params)
      # check error condition No files                                                                                                                                                                                                      
      return render_json_response(response_type: :bad_request, options: { message: 'Error! No file to save' }) unless params.key?(:file_set) && params.fetch(:file_set).key?(:files)

      file = params[:file_set][:files].detect { |f| f.respond_to?(:original_filename) }
      if !file
        render_json_response(response_type: :bad_request, options: { message: 'Error! No file for upload', description: 'unknown file' })
      elsif empty_file?(file)
        render_json_response(response_type: :unprocessable_entity, options: { errors: { files: "#{file.original_filename} has no content! (Zero length file)" }, description: t('curation_concerns.api.unprocessable_entity.empty_file') })
      else
        # process_file(file)
        create_work_for_file
        respond_to do |format|
          format.json do
            render json: { status: 'ok' }
          end
        end
      end
    rescue RSolr::Error::Http => error
      logger.error "FileSetController::create rescued #{error.class}\n\t#{error}\n #{error.backtrace.join("\n")}\n\n"
      render_json_response(response_type: :internal_error, options: { message: 'Error occurred while creating a FileSet.' })
    ensure
      # remove the tempfile (only if it is a temp file)                                                                                                                                                                                     
      file.tempfile.delete if file.respond_to?(:tempfile)
    end

    def create_work_for_file()
      item_name = params[:file].split('/').last.gsub(/\.zip/, '')

      Zip::File.open(params[:file]) do |zip_file|

        # Handle entries one by one
        zip_file.each do |entry|

          # Extract to file/directory/symlink
          if not File.exists? entry.name
            entry.extract(entry.name)
        
            # Read into memory
            unless File.directory? entry.name
              File.open(entry.name, 'wb') { |file| file.write(entry.get_input_stream.read) } 
            end
          end
        end
      end

      ### Create the CurationConcern Work
      work = curation_concern.new

      ## BaseActor#apply_creation_data_to_curation_concern
      work.apply_depositor_metadata(user.user_key)
      work.date_uploaded = CurationConcerns::TimeService.time_in_utc

      ## BaseActor#apply_save_data_to_curation_concern
      work.date_modified = CurationConcerns::TimeService.time_in_utc

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

#      relation = :original_file

      files.each do |file|
        process_file(file, work.id)
      end
    end

    protected

    def process_file(file, parent_id)
      # update_metadata_from_upload_screen
      # actor.create_metadata(find_parent_by_id, params[:file_set])
      
      actor.create_metadata(parent_id, params[:file_set])
      actor.create_content(file)
=begin
      if actor.create_content(file)
        respond_to do |format|
          format.json do
#            render 'jq_upload', status: :created, location: polymorphic_path([main_app, curation_concern])
            render json: { status: 'ok' }
          end
        end
      else
        msg = curation_concern.errors.full_messages.join(', ')
#        flash[:error] = msg
#        json_error "Error creating file #{file.original_filename}: #{msg}"
        render json: { status: 'error', message: msg }
      end
=end
    end
  end
end
