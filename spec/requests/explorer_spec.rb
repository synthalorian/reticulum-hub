require 'rails_helper'

RSpec.describe "Explorers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get explorer_index_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      node = create(:node)
      get explorer_path(node)
      expect(response).to have_http_status(:success)
    end
  end
end
