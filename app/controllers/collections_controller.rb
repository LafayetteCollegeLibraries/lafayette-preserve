class CollectionsController < ApplicationController
  include CurationConcerns::CollectionsControllerBehavior
  include Sufia::CollectionsControllerBehavior
  include LafayetteConcerns::CollectionsControllerBehavior
end
