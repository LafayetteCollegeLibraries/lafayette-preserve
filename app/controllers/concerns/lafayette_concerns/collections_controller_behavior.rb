module LafayetteConcerns
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

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
          render 'curation_concerns/collections/show', status: :ok
        end
      end
    end
  end
end
