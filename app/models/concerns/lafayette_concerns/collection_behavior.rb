module LafayetteConcerns
  module CollectionBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Collections::Metadata
  end
end
