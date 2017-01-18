require "spec_helper"

describe "term management for controlled vocabularies", :type => :request do
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

  describe 'retrieving the attributes of a vocabulary term' do
    before do
      @term = LafayetteConcerns::Term.new('http://namespace.org/ns/testVocabulary/testTerm')
      @term.persist!

      get '/terms/testVocabulary/testTerm', format: :json
    end

    after { @term.destroy }

    it "renders the attributes of a vocabulary term" do

      expect(response).to render_template(:show)
      expect(JSON.parse(response.body)).to include('uri' => "http://namespace.org/ns/testVocabulary/testTerm")
      expect(JSON.parse(response.body)).to include('label' => [])
      expect(JSON.parse(response.body)).to include('alt_label' => [])
      expect(JSON.parse(response.body)).to include('pref_label' => [])
      expect(JSON.parse(response.body)).to include('hidden_label' => [])
    end
  end
end
