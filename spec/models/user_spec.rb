require 'spec_helper'

describe User do
  describe "#local_email_part" do
    it "returns the local part of the email" do
      user = FactoryGirl.create(:user, email: "erica.p.kwan@codeforamerica.org")
      user.local_email_part.should == "erica.p.kwan"
    end
  end
end
