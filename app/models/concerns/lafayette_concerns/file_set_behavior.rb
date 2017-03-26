module LafayetteConcerns
  module FileSetBehavior
    extend ActiveSupport::Concern

    include LafayetteConcerns::FileSet::Derivatives

  end
end
