# Generated via
#  `rails generate curation_concerns:work GenericWork`

module CurationConcerns
  class GenericWorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = GenericWork
    # skip_authorize_resource :only => [ :update, :destroy ]
    skip_authorize_resource :only => [ :update ]
    # skip_load_and_authorize_resource only: [:destroy]

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
          attributes = form_class.model_attributes(params[hash_key_for_curation_concern])
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

=begin
    # See CurationsConcerns::Actors::FileActor
    def ingest_file(file)
      working_file = WorkingDirectory.copy_file_to_working_directory(file, file_set.id)
      mime_type = file.respond_to?(:content_type) ? file.content_type : nil
      IngestFileJob.perform_later(file_set, working_file, mime_type, user, relation)
      true
    end

    # See CurationConcerns::Actors::FileSetActor
    # @param [File, ActionDigest::HTTP::UploadedFile, Tempfile] file the file uploaded by the user.
    # @param [String] relation ('original_file')
    def create_content(file, relation = 'original_file')
      # If the file set doesn't have a title or label assigned, set a default.
      file_set.label ||= file.respond_to?(:original_filename) ? file.original_filename : ::File.basename(file)
      file_set.title = [file_set.label] if file_set.title.blank?

      # Need to save the file_set in order to get an id
      return false unless file_set.save

      # file_actor_class.new(file_set, relation, user).ingest_file(file)
      ingest_file(file)
      true
    end

    # See CurationConcerns::FileSetsController
    def create_from_upload(params)
      # check error condition No files
      return render_json_response(response_type: :bad_request, options: { message: 'Error! No file to save' }) unless params.key?(:file_set) && params.fetch(:file_set).key?(:files)

      file = params[:file_set][:files].detect { |f| f.respond_to?(:original_filename) }
      if !file
        render_json_response(response_type: :bad_request, options: { message: 'Error! No file for upload', description: 'unknown file' })
      elsif empty_file?(file)
        render_json_response(response_type: :unprocessable_entity, options: { errors: { files: "#{file.original_filename} has no content! (Zero length file)" }, description: t('curation_concerns.api.unprocessable_entity.empty_file') })
      else
        process_file(file)
      end
    rescue RSolr::Error::Http => error
      logger.error "FileSetController::create rescued #{error.class}\n\t#{error}\n #{error.backtrace.join("\n")}\n\n"
      render_json_response(response_type: :internal_error, options: { message: 'Error occurred while creating a FileSet.' })
    ensure
      # remove the tempfile (only if it is a temp file)
      file.tempfile.delete if file.respond_to?(:tempfile)
    end
=end

    def new
      respond_to do |wants|
        wants.json do
          # Create the FileSet
          

          # Create the CurationConcern Resource

          # See CurationConcerns::Actors::BaseActor
          attributes = form_class.model_attributes(params[hash_key_for_curation_concern])
          attributes[:rights] = Array(attributes[:rights]) if attributes.key? :rights
          remove_blank_attributes!(attributes)
          curation_concern.attributes = attributes.symbolize_keys
          curation_concern.date_modified = CurationConcerns::TimeService.time_in_utc
          curation_concern.save!

          
        end
        wants.html { super }
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
            @vocabularies += collection.uses_vocabulary.map { |uri| Vocabulary.find(uri) }
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
