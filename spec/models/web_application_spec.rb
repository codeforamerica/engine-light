require 'spec_helper'

describe WebApplication do
  let(:status_url)        { "http://www.codeforamerica.org/.well-known/status" } 
  let(:web_application)   { FactoryGirl.build(:web_application_with_user, status_url: status_url) }
  let(:valid_body_string) { "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}" } 

  describe "#get_status" do
    it "returns 'ok' when the get request is successful" do
      FakeWeb.register_uri(:get, status_url, body: valid_body_string)
      web_application.get_status.should == "ok"
    end

    it "returns 'down' when the get request is unsuccessful" do
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", :status => ["500", "Internal Server Error"])
      web_application.get_status.should == "down"
    end
  end

  describe "validations" do
    it "does not allow a user to belong to the web app more than once" do
      FakeWeb.register_uri(:get, status_url, body: valid_body_string)
      user = FactoryGirl.create(:user)
      web_application = FactoryGirl.create(:web_application, status_url: status_url)
      web_application.update_attributes(users: [user])
      expect { web_application.users << user }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "cannot have an invalid status url" do
      FakeWeb.register_uri(:get, status_url, status: ["500", "Internal Server Error"])
      web_application.should_not be_valid
    end
  end
end
