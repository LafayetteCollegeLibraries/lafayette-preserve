require 'spec_helper'

describe LafayetteConcerns::VocabulariesController, :type => :controller do
  let(:user) { create(:user) }
  before { sign_in user }

  before(:example) do
    @vocab = LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary')
    @vocab.persist!
    @term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
    @term.persist!
  end

  after(:example) do
    @term.destroy
    @vocab.destroy
  end

  context "JSON" do
#    let(:resource) { LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary').persist! }
#    let(:term_resource) { LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm').persist! }

#    let(:resource) { create(:vocabulary) }
#    let(:term_resource) { create(:term) }

#    let(:resource_request) { get :show, params: { id: resource, format: :json } }
#    let(:resource) { create(:private_generic_work, user: user) }

    describe 'replacing the attributes of a vocabulary with no terms' do
      before { put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [] }, format: :json }
      subject { response }

      it "returns 200" do

        expect(response.code).to eq "200"
      end
    end

    describe 'replacing a vocabulary with different attributes and terms' do
      before { put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/testVocabulary/testTerm', label: ['replaced term label'] } ] }, format: :json }
      subject { response }
      it "returns 200" do

        expect(response.code).to eq "200"
      end
    end

    describe 'replacing a vocabulary using a foreign (or non-existent) term' do
      before { put :update, id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/anotherVocabulary/testTerm', label: ['replaced term label'] } ] }, format: :json }
      subject { response }
      it "returns 400" do

        expect(response.code).to eq "400"
      end
    end

    describe 'updating the attributes for a vocabulary' do
      before { patch :update, id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'] }, format: :json }
      subject { response }
      it "returns 200, renders show template sets location header" do

        expect(response.code).to eq "200"
      end
    end

    describe 'updating the terms for a vocabulary' do
      before { patch :update, id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'], terms: [ { uri: 'http://authority.localhost.localdomain/ns/testVocabulary/testTerm', label: ['updated term label'] } ] }, format: :json }
      subject { response }
      it "returns 200, renders show template sets location header" do

        expect(response.code).to eq "200"

      end
    end
  end
end

