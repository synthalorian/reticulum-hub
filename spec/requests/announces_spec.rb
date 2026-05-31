require 'rails_helper'

RSpec.describe "Announces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/announces/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/announces/create"
      expect(response).to have_http_status(:success)
    end
  end

end
