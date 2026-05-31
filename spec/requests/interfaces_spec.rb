require 'rails_helper'

RSpec.describe "Interfaces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get interfaces_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      interface = create(:interface)
      get interface_path(interface)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      interface = create(:interface)
      get edit_interface_path(interface)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates an interface and redirects" do
      interface = create(:interface)
      patch interface_path(interface), params: { interface: { name: "Updated Name" } }
      expect(response).to have_http_status(:redirect)
    end
  end
end
