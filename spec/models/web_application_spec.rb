require 'spec_helper'

describe WebApplication do
  describe "#get_status" do
    let(:web_app) { FactoryGirl.create(:web_application) }

    it "returns a hash of status information" do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", body: body_string)
      web_app.get_status.should == "ok"
    end

    it "raises when the get request is unsuccessful" do
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", :status => ["500", "Internal Server Error"])
      expect { web_app.get_status }.to raise_error
    end
  end
end
