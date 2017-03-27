require 'spec_helper'

describe 'curation_concerns/generic_works/update.json.jbuilder' do

  let(:curation_concern) { FactoryGirl.create(:work_with_representative_file) }

  before do
    curation_concern.thumbnail = curation_concern.ordered_members.to_a.last
    assign(:curation_concern, curation_concern)
    render
  end

  it "renders json of the curation_concern" do
    json = JSON.parse(rendered)
    expect(json['id']).to eq curation_concern.id
    expect(json['title']).to eq curation_concern.title
  end
end
