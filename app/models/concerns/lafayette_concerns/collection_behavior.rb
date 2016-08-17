module LafayetteConcerns
  module CollectionBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Collections::Metadata

#    module ClassMethods
#      def find(id)
#        collection = super(id)
#      end
#    end
  end
end
