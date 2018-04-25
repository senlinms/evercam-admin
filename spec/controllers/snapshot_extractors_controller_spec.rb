require 'rails_helper'

RSpec.describe SnapshotExtractorsController, type: :controller do
  let!(:snapshot_extractor) { create(:snapshot_extractor) }

  describe 'GET #index without auth' do
    it "redirects to signin" do
      get :index
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'with auth' do
    describe 'GET #index' do
      it "renders the :index" do
        get :index
        expect(response.status).to eq(302)
      end
    end
  end
end
