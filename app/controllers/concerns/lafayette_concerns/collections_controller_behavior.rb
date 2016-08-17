module LafayetteConcerns
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    included do
      # actions: audit, index, create, new, edit, show, update, destroy, permissions, citation                                                                                                                                           
      before_action :authenticate_user!, except: [:show, :update]
      load_and_authorize_resource except: [:index, :show, :update], instance_name: :collection
      skip_authorize_resource :only => :update
    end

    def show
      respond_to do |format|
        format.html do
          presenter
          query_collection_members
        end
        format.json do
          # Query Solr for the collection.
          # run the solr query to find the collection members
          response = repository.search(collection_search_builder.query)
          collection_document = response.documents.first
          raise CanCan::AccessDenied unless collection_document

          @collection = Collection.find(collection_document[:id])
          @collection.uses_vocabulary = @collection.uses_vocabulary.map { |uri| Vocabulary.find(uri) }

          render 'curation_concerns/collections/show', status: :ok
        end
      end
    end
  end
end
