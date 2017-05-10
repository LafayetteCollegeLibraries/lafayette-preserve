require 'spec_helper'

describe CurationConcerns::GenericWorksController do
  let(:user) { create(:user) }
  before { sign_in user }

  context "JSON" do
    let(:resource) { create(:generic_work, user: user) }
    let(:resource_request) { get :show, params: { id: resource, format: :json } }
    subject { response }

    describe 'updates over REST' do

      before do
        put :update, params: { id: resource, generic_work: { title: ['updated title'] }, format: :json }
      end
      it "updates the metadata for the GenericWork" do
        expect(assigns[:curation_concern]).to be_instance_of GenericWork
        expect(controller).to render_template(:update)
        expect(response.code).to eq "200"
        created_resource = assigns[:curation_concern]
        expect(created_resource.title).to include('updated title')
      end
    end
  end
end
