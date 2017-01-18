
FactoryGirl.define do

  factory :vocabulary, class: LafayetteConcerns::Vocabulary do
      transient do
        user { FactoryGirl.create(:user) }
      end
      
      uri 'http://namespace.org/ns/testVocabulary'
      label ['Test vocabulary']
      pref_label ['Preferred label for the test vocabulary']
      alt_label ['Alternate label for the test vocabulary']
      hidden_label ['Hidden label for the test vocabulary']

      after(:build) do |vocabulary, evaluator|
        # To be implemented for supporting authentication
        # work.apply_depositor_metadata(evaluator.user.user_key)
      end

#      factory :vocabulary_with_terms do
#        before(:create) do |vocabulary, evaluator|
#          vocabulary.ordered_members << FactoryGirl.create(:term, user: evaluator.user, title: ['A Contained FileSet'])
#        end
#      end
  end
end

