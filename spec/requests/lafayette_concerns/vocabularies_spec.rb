require "spec_helper"

describe "controlled vocabulary management", :type => :request do
#  let(:user) { create(:user) }
  before do
    #    sign_in user
  end

  before(:example) do
    @vocab = LafayetteConcerns::Vocabulary.new('http://namespace.org/ns/testVocabulary')
    @vocab.persist!
  end

  after(:example) do
    @vocab.destroy
  end

  describe 'replacing the attributes of a vocabulary with no terms' do
    before { put '/vocabularies', id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [] }, format: :json }

    it "replacing the attributes of a vocabulary with no terms" do

      expect(response).to render_template(:update)
      expect(JSON.parse(response.body)).to include('uri' => "http://namespace.org/ns/testVocabulary")
      expect(JSON.parse(response.body)).to include('label' => ['replaced label'])
      expect(JSON.parse(response.body)).to include('terms' => [])
    end
  end

  describe 'replacing the attributes and terms of a vocabulary' do
    before do
      @term = LafayetteConcerns::Term.new('http://namespace.org/ns/testVocabulary/testTerm')
      @term.persist!

      put '/vocabularies', id: 'testVocabulary', vocabulary: { label: ['replaced label'], terms: [ { uri: 'http://namespace.org/ns/testVocabulary/testTerm', label: ['replaced term label'] } ] }, format: :json
    end

    after do
      @term.destroy
    end

    it "replacing the attributes and terms of a vocabulary" do

      expect(response).to render_template(:update)
      expect(JSON.parse(response.body)).to include('uri' => "http://namespace.org/ns/testVocabulary")
      expect(JSON.parse(response.body)).to include('label' => ['replaced label'])
      expect(JSON.parse(response.body)).to include('terms' => [{ 'uri' => 'http://namespace.org/ns/testVocabulary/testTerm', 'label' => ['replaced term label'], 'alt_label' => [], 'pref_label' => [], 'hidden_label' => [] }])
    end
  end

  describe 'updating the attributes for a vocabulary' do
    before { patch '/vocabularies', id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'] }, format: :json }

    it "updating the attributes for a vocabulary" do

      expect(response).to render_template(:update)
      expect(JSON.parse(response.body)).to include('uri' => "http://namespace.org/ns/testVocabulary")
      expect(JSON.parse(response.body)).to include('label' => ['updated label'])
      expect(JSON.parse(response.body)).to include('alt_label' => ['updated alternate label'])
      expect(JSON.parse(response.body)).to include('terms' => [])
    end
  end

  describe 'updating the terms for a vocabulary' do
    before do
      @term = LafayetteConcerns::Term.new('http://namespace.org/ns/testVocabulary/testTerm')
      @term.persist!

      patch '/vocabularies', id: 'testVocabulary', vocabulary: { label: ['updated label'], alt_label: ['updated alternate label'], terms: [ { uri: 'http://namespace.org/ns/testVocabulary/testTerm', label: ['updated term label'] } ] }, format: :json
    end

    after do
      @term.destroy
    end

    it "updating the terms for a vocabulary" do

      expect(response).to render_template(:update)
      expect(JSON.parse(response.body)).to include('uri' => "http://namespace.org/ns/testVocabulary")
      expect(JSON.parse(response.body)).to include('label' => ['updated label'])
      expect(JSON.parse(response.body)).to include('alt_label' => ['updated alternate label'])

      expect(JSON.parse(response.body)).to include('terms' => [{ 'uri' => 'http://namespace.org/ns/testVocabulary/testTerm', 'label' => ['updated term label'], 'alt_label' => [], 'pref_label' => [], 'hidden_label' => [] }])
    end
  end
end
