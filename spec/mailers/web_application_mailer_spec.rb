require 'spec_helper'

describe WebApplicationMailer do
  describe "#outage_notification" do
    let(:status_url)      { "http://www.codeforamerica.org/.well-known/status" }
    let(:web_application) { FactoryGirl.create(:web_application_with_user, status_url: status_url) }

    before do
      body = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, status_url, body: body)
    end

    it "sends the email" do
      WebApplicationMailer.outage_notification(web_application).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
end