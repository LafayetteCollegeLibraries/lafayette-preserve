# Generated via
#  `rails generate curation_concerns:work GenericWork`

module CurationConcerns
  class GenericWorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = GenericWork
    skip_authorize_resource :only => [ :update ]

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
