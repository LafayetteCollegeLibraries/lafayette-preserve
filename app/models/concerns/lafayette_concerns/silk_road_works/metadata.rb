module LafayetteConcerns::SilkRoadWorks
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :date_image_upper, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageUpper')
      # property :date_image_lower, predicate: ::RDF::URI.new('http://authority.lafayette.edu/metadb#dateImageLower')
      nil
    end
  end
end
