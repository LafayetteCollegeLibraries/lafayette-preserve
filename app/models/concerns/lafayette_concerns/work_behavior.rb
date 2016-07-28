module LafayetteConcerns
  module WorkBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Works::Metadata
  end
end
