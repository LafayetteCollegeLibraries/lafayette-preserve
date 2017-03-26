require 'spec_helper'

describe LafayetteConcerns::TermsController, :type => :controller do
  let(:user) { create(:user) }
  before { sign_in user }

  before(:example) do
    @vocab = LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary')
    @vocab.persist!
  end

  after(:example) { @vocab.destroy }

  context "JSON" do

    describe 'retrieving the attributes of a term' do
      before do
        @term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
        @term.persist!
        get :show, vocabulary_id: 'testVocabulary', id: 'testTerm', format: :json
      end

      after { @term.destroy }

      subject { response }

      it "gets the attributes" do
        expect(controller).to render_template(:show)
        expect(response.code).to eq "200"
        expect(assigns[:term]).to be_instance_of LafayetteConcerns::Term
        created_resource = assigns[:term]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary/testTerm")
      end
    end
  end
end
