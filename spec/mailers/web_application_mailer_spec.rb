require 'spec_helper'

describe WebApplicationMailer do
  describe "#outage_notification" do
    let(:web_application) { FactoryGirl.create(:web_application_with_user) }

    it "sends the email" do
      WebApplicationMailer.outage_notification(web_application).deliver
      ActionMailer::Base.deliveries.count.should == 1
    end
  end
end