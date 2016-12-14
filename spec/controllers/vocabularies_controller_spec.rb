require 'rails_helper'

describe LafayetteConcerns::VocabulariesController do
  let(:user) { create(:user) }
  before { sign_in user }

  it "has tests" do
    skip "Add your tests here"
  end

  context "JSON" do
#    let(:resource) { create(:private_generic_work, user: user) }
#    let(:resource_request) { get :show, params: { id: resource, format: :json } }
#    subject { response }
    let(:resource) { create(:private_generic_work, user: user) }

    describe 'replacing the attributes of a vocabulary' do
      before { put :update, params: { id: resource, generic_work: { title: ['updated title'] }, format: :json } }
      it "returns 200, renders show template sets location header" do
        # Ensure that @curation_concern is set for jbuilder template to use
#        expect(assigns[:curation_concern]).to be_instance_of GenericWork
#        expect(controller).to render_template('curation_concerns/base/show')
        expect(response.code).to eq "200"
#        created_resource = assigns[:curation_concern]
#        expect(response.location).to eq main_app.curation_concerns_generic_work_path(created_resource)
      end
    end

    describe 'updating the attributes for a vocabulary' do
      before { patch :update, params: { id: resource, generic_work: { title: ['updated title'] }, format: :json } }
      it "returns 200, renders show template sets location header" do

        expect(response.code).to eq "200"
      end
    end

    describe 'updating the terms for a vocabulary' do
      before { patch :update, params: { id: resource, generic_work: { title: ['updated title'] }, format: :json } }
      it "returns 200, renders show template sets location header" do

        expect(response.code).to eq "200"
      end
    end

  end
end
