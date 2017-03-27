require 'spec_helper'

describe LafayetteConcerns::VocabulariesController, :type => :controller do
  let(:user) { create(:user) }
  before { sign_in user }

  context "JSON" do
    before() do
      @vocabulary = LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary')
      @vocabulary.persist!
    end

    after { @vocabulary.destroy }

    describe 'retrieving the attributes of a term' do
      before do
        get :show, vocabulary_id: 'testVocabulary', id: 'testVocabulary', format: :json
      end
      subject { response }        

      it "gets the attributes" do
        expect(controller).to render_template(:show)
        expect(response.code).to eq "200"
        expect(assigns[:vocabulary]).to be_instance_of LafayetteConcerns::Vocabulary
        created_resource = assigns[:vocabulary]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary")
      end
    end    

    describe 'replacing the attributes of a vocabulary with no terms' do
      before { put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [] }, format: :json }
      subject { response }

      it "renders the updated gets attribute and empty terms" do
        expect(controller).to render_template(:update)
        expect(response.code).to eq "200"
        expect(assigns[:vocabulary]).to be_instance_of LafayetteConcerns::Vocabulary
        created_resource = assigns[:vocabulary]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary")
        expect(created_resource.label).to eq(["replaced label"])
        expect(created_resource.children).to eq([])
      end
    end

    describe 'replacing a vocabulary with different attributes and terms' do
      before do
        @term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
        @term.persist!
        
        put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/testVocabulary/testTerm', label: ['replaced term label'] } ] }, format: :json
      end

      after do
        @term.destroy
      end

      subject { response }

      it "renders the new attributes and newly assigned terms" do

        expect(controller).to render_template(:update)
        expect(response.code).to eq "200"
        expect(assigns[:vocabulary]).to be_instance_of LafayetteConcerns::Vocabulary
        created_resource = assigns[:vocabulary]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary")
        expect(created_resource.label).to eq(["replaced label"])
        expect(created_resource.children.size).to eq(1)
        expect(created_resource.children.first).to be_instance_of LafayetteConcerns::Term
        expect(created_resource.children.first.rdf_subject).to eq('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
        expect(created_resource.children.first.label).to eq(['replaced term label'])
      end
    end

    describe 'replacing a vocabulary using a foreign (or non-existent) term' do
      before { put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/anotherVocabulary/testTerm', label: ['replaced term label'] } ] }, format: :json }
      subject { response }
      it "returns raises an error for the foreign term" do

        expect(response.code).to eq "400"
      end
      
    end

    describe 'updating the attributes for a vocabulary' do
      before { patch :update, id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'] }, format: :json }
      subject { response }

      it "renders the updated gets attribute and empty terms" do
        expect(controller).to render_template(:update)
        expect(response.code).to eq "200"
        expect(assigns[:vocabulary]).to be_instance_of LafayetteConcerns::Vocabulary
        created_resource = assigns[:vocabulary]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary")
        expect(created_resource.label).to eq(["updated label"])
        expect(created_resource.alt_label).to eq(["updated alternate label"])

      end        

    end

    describe 'updating the terms for a vocabulary' do
      before { patch :update, id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/testVocabulary/testTerm', label: ['updated term label'] } ] }, format: :json }
      subject { response }

      it "renders the new attributes and newly assigned terms" do

        expect(controller).to render_template(:update)
        expect(response.code).to eq "200"
        expect(assigns[:vocabulary]).to be_instance_of LafayetteConcerns::Vocabulary
        created_resource = assigns[:vocabulary]
        expect(created_resource.rdf_subject).to eq("http://authority.localhost.localdomain/ns/testVocabulary")
        expect(created_resource.label).to eq(["updated label"])
        expect(created_resource.alt_label).to eq(["updated alternate label"])
        expect(created_resource.children.size).to eq(1)
        expect(created_resource.children.first).to be_instance_of LafayetteConcerns::Term
        expect(created_resource.children.first.rdf_subject).to eq('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
        expect(created_resource.children.first.label).to eq(['updated term label'])
      end      
    end
  end
end

