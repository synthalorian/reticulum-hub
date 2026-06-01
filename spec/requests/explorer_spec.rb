require 'rails_helper'

RSpec.describe "Explorers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get explorer_index_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get explorer_index_path
      expect(response).to render_template(:index)
    end

    it "assigns nodes" do
      get explorer_index_path
      expect(assigns(:nodes)).not_to be_nil
    end

    it "assigns network_map" do
      get explorer_index_path
      expect(assigns(:network_map)).not_to be_nil
    end
  end

  describe "GET /show" do
    it "returns http success" do
      node = create(:node)
      get explorer_path(node)
      expect(response).to have_http_status(:success)
    end

    it "renders the show template" do
      node = create(:node)
      get explorer_path(node)
      expect(response).to render_template(:show)
    end
  end
end
