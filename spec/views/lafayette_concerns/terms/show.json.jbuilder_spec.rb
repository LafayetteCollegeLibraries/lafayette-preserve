require 'spec_helper'

describe 'lafayette_concerns/terms/show.json.jbuilder' do
  let(:term) do
    term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/testVocabulary/testTerm')
    term.persist!
    term
  end

  before do
    assign(:term, term)
    render
  end

  it "renders JSON of the term" do
    json = JSON.parse(rendered)
    expect(json['uri']).to eq term.uri
    expect(json['label']).to match_array term.label
    expect(json['alt_label']).to match_array term.alt_label
    expect(json['pref_label']).to match_array term.pref_label
    expect(json['hidden_label']).to match_array term.hidden_label
  end
end
