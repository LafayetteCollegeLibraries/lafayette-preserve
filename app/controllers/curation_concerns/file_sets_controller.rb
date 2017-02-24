module CurationConcerns
  class FileSetsController < ApplicationController
    include CurationConcerns::FileSetsControllerBehavior
    include LafayetteConcerns::FileSetsControllerBehavior
  end
end
