# Generated via
#  `rails generate curation_concerns:work GenericWork`

module CurationConcerns
  class GenericWorksController < ApplicationController
    include CurationConcerns::CurationConcernController
    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    self.curation_concern_type = GenericWork

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
