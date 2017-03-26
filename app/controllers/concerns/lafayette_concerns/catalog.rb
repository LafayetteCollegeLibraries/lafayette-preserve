module LafayetteConcerns
  module Catalog
    extend ActiveSupport::Concern
    included do

      def search_builder_class
        LafayetteConcerns::CatalogSearchBuilder
      end
    end
  end
end
