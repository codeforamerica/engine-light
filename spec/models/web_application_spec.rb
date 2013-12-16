require 'spec_helper'

describe WebApplication do
  let(:status_url)        { "http://www.codeforamerica.org/.well-known/status" } 
  let(:web_application)   { FactoryGirl.build(:web_application_with_user, status_url: status_url) }
  let(:valid_body_string) { "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":[\"Akismet\",\"Scribd\"],\"resources\":{\"Sendgrid\":6.545}}" } 
  before                  { FakeWeb.register_uri(:get, status_url, body: valid_body_string) }

  describe "#get_current_status!" do
    context "the get request is successful" do
      before { web_application.get_current_status }

      it "sets current status to 'ok'" do
        web_application.current_status.should == "ok"
      end

      it "sets status_checked_at" do
        web_application.status_checked_at.should == Time.at(1379539549).utc
      end

      it "sets resources" do
        web_application.resources.should == {"Sendgrid" => 6.545}
      end

      it "sets dependencies" do
        web_application.dependencies.should == ["Akismet", "Scribd"]
      end
    end

    context "the get request fails" do
      before do
        Timecop.freeze
        FakeWeb.register_uri(:get, status_url, :status => ["500", "Internal Server Error"])
        web_application.get_current_status
      end

      it "sets current status to 'application unreachable' when the get request is unsuccessful" do
        web_application.current_status.should == "application unreachable"
      end

      it "does not set resources or dependencies" do
        web_application.resources.should be_nil
        web_application.dependencies.should be_nil
      end

      it "sets the status checked at time to when the check was performed" do
        web_application.status_checked_at.should == Time.now.utc
      end
    end
  end

  describe "#root_url" do
    it "returns the URL scheme and domain" do
      web_application.root_url.should == "http://www.codeforamerica.org"
    end
  end

  describe "validations" do
    it "does not allow a user to belong to the web app more than once" do
      web_application = FactoryGirl.create(:web_application_with_user)
      user = web_application.users.first
      expect{ web_application.users << user }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "it considers a status url invalid if it has changed and is unreachable" do
      status_url = "http://idontwork.com"
      web_application.status_url = status_url
      FakeWeb.register_uri(:get, status_url, status: ["500", "Internal Server Error"])
      web_application.should_not be_valid
    end

    it "does considers a status url valid if it has not changed and is unreachable" do
      web_application = FactoryGirl.create(:web_application_with_user, status_url: status_url)
      FakeWeb.register_uri(:get, status_url, status: ["500", "Internal Server Error"])
      web_application.should be_valid
    end
  end
end
