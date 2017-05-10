require "spec_helper"

describe "term management for controlled vocabularies", :type => :request do

  before(:all) do
    @vocab = LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary')
    @vocab.persist!
  end

  after(:all) do
    @vocab.destroy
  end

  describe 'retrieving the attributes of a vocabulary term' do
    before(:each) do
      @term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
      @term.persist!

      get '/terms/testVocabulary/testTerm', params: { format: :json }
    end

    after(:each) { @term.destroy }

    it "renders the attributes of a vocabulary term" do


      expect(response).to render_template(:show)
      expect(JSON.parse(response.body)).to include('uri' => "http://authority.localhost.localdomain/ns/testVocabulary/testTerm")
      expect(JSON.parse(response.body)).to include('label' => [])
      expect(JSON.parse(response.body)).to include('alt_label' => [])
      expect(JSON.parse(response.body)).to include('pref_label' => [])
      expect(JSON.parse(response.body)).to include('hidden_label' => [])
    end
  end
end
