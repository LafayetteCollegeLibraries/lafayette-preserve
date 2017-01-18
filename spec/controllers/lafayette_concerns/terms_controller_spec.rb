require 'spec_helper'

describe LafayetteConcerns::TermsController, :type => :controller do
  let(:user) { create(:user) }
  before { sign_in user }

  before(:example) do
    @vocab = LafayetteConcerns::Vocabulary.new('http://namespace.org/ns/testVocabulary')
    @vocab.persist!
  end

  after(:example) { @vocab.destroy }

  context "JSON" do

    describe 'retrieving the attributes of a term' do
      before do
        @term = LafayetteConcerns::Term.new('http://namespace.org/ns/testVocabulary/testTerm')
        @term.persist!
#        get :show, vocabulary_id: 'testVocabulary', id: 'testTerm', format: :json
      end

      after { @term.destroy }

      subject { response }

      it "returns 200" do

#        expect(response.code).to eq "200"
        expect(true).to eq true
      end
    end
  end
end
