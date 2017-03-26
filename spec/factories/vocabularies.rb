
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

  end
end
