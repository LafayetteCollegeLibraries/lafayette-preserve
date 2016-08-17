module LafayetteConcerns::Collections
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :uses_vocabulary, predicate: "http://www.w3.org/ns/rdfa#usesVocabulary"
    end
  end
end
