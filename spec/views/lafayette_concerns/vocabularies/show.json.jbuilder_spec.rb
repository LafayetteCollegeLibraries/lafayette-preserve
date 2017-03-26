require 'spec_helper'

describe 'lafayette_concerns/vocabularies/show.json.jbuilder' do
  let(:vocabulary) do
    vocab = LafayetteConcerns::Vocabulary.new('http://authority.localhost.localdomain/ns/testVocabulary')
    vocab.persist!
    vocab
  end

  before do
    assign(:vocabulary, vocabulary)
    render
  end

  it "renders JSON of the vocabulary" do
    json = JSON.parse(rendered)
    expect(json['uri']).to eq vocabulary.uri
    expect(json['label']).to match_array vocabulary.label
    expect(json['alt_label']).to match_array vocabulary.alt_label
    expect(json['pref_label']).to match_array vocabulary.pref_label
    expect(json['hidden_label']).to match_array vocabulary.hidden_label
  end
end
