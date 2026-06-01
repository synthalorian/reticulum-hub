require 'rails_helper'

RSpec.describe "Interfaces", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get interfaces_path
      expect(response).to have_http_status(:success)
    end

    it "renders the index template" do
      get interfaces_path
      expect(response).to render_template(:index)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      interface = create(:interface)
      get interface_path(interface)
      expect(response).to have_http_status(:success)
    end

    it "renders the show template" do
      interface = create(:interface)
      get interface_path(interface)
      expect(response).to render_template(:show)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      interface = create(:interface)
      get edit_interface_path(interface)
      expect(response).to have_http_status(:success)
    end

    it "renders the edit template" do
      interface = create(:interface)
      get edit_interface_path(interface)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH /update" do
    it "updates an interface and redirects" do
      interface = create(:interface)
      patch interface_path(interface), params: { interface: { config: { port: 4242 }.to_json } }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(interfaces_path)
    end
  end

  describe "POST /enable" do
    it "redirects to index" do
      interface = create(:interface)
      post enable_interface_path(interface.name)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(interfaces_path)
    end
  end

  describe "POST /disable" do
    it "redirects to index" do
      interface = create(:interface)
      post disable_interface_path(interface.name)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(interfaces_path)
    end
  end

  describe "POST /restart" do
    it "redirects to index" do
      interface = create(:interface)
      post restart_interface_path(interface.name)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(interfaces_path)
    end
  end
end
