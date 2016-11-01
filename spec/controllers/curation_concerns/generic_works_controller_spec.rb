require 'spec_helper'

describe CurationConcerns::GenericWorksController do
  let(:user) { create(:user) }
  before { sign_in user }

  context "JSON" do
=begin
    let(:resource) { create(:private_generic_work, user: user) }
    let(:resource_request) { get :show, params: { id: resource, format: :json } }
    subject { response }

    describe 'updated' do
      before { put :update, params: { id: resource, generic_work: { title: ['updated title'] }, format: :json } }
      it "returns 200, renders show template sets location header" do
        # Ensure that @curation_concern is set for jbuilder template to use
        expect(assigns[:curation_concern]).to be_instance_of GenericWork
        expect(controller).to render_template('curation_concerns/base/show')
        expect(response.code).to eq "200"
        created_resource = assigns[:curation_concern]
        expect(response.location).to eq main_app.curation_concerns_generic_work_path(created_resource)
      end
    end
=end

  end
end
