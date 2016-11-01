class GenericWork < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Sufia::WorkBehavior
  include LafayetteConcerns::WorkBehavior
  include LafayetteConcerns::EastAsiaWorkBehavior
  include LafayetteConcerns::SilkRoadWorkBehavior
  include LafayetteConcerns::CasualtiesWorkBehavior
  self.human_readable_type = 'Work'
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
end
