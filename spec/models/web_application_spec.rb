require 'spec_helper'

describe WebApplication do
  describe "#get_status" do
    before do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", body: body_string)
    end

    it "returns a hash of status information" do
      web_app = FactoryGirl.create(:web_application)
      web_app.get_status.should == "ok"
    end
  end
end
