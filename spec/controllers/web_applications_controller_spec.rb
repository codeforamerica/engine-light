require 'spec_helper'

describe WebApplicationsController do
  describe "#show" do
    before do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", body: body_string)
    end

    it "returns ok with a valid application" do
      web_app = FactoryGirl.create(:web_application, name: "monkey")
      get :show, id: web_app.name
      response.should be_success
    end

    it "throws an exception when passed a non-existent application" do
      expect{
        get :show, id: "pretend_monkey"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#index" do
    it "returns ok" do
      get :index
      response.should be_success
    end
  end
end
