class BatchEditsController < ApplicationController
  include Hydra::BatchEditBehavior
  include FileSetHelper
  include Sufia::BatchEditsControllerBehavior
  include LafayetteConcerns::BatchEditsControllerBehavior
end
