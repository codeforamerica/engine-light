require 'spec_helper'

describe WebApplicationsController do
  describe "#show" do
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
end
