require "spec_helper"
require "rake"

describe "check_app_statuses" do
  let(:rake)       { Rake::Application.new }
  let(:task_name)  { "check_app_statuses" }
  let(:task_path)  { "lib/tasks/scheduler" }
  let(:status_url) { "http://www.codeforamerica.org/.well-known/status" }
  let(:valid_body_string) { "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":[\"Akismet\",\"Scribd\"],\"resources\":{\"Sendgrid\":6.545}}" } 

  subject          { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == Rails.root.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)
    Rake::Task.define_task(:environment)
    ActionMailer::Base.deliveries = []
    FakeWeb.register_uri(:get, status_url, body: valid_body_string)
    @web_app = FactoryGirl.create(:web_application_with_user, status_url: status_url, name: "fdsdfjl")
    Timecop.freeze
    Kernel.stub(:sleep)
  end

  after do
    ActionMailer::Base.deliveries.clear
  end

  its(:prerequisites) { should include("environment") }

  context "an application is down" do
    before do
      FakeWeb.register_uri(:get, status_url, status: ["500", "Internal Server Error"])
    end

    context "no downtime notification has been sent" do
      it "sends a downtime notification email if another check confirms the app is down" do
        WebApplication.stub(:all).and_return([@web_app])
        subject.invoke
        ActionMailer::Base.deliveries.first.subject == "#{@web_app.name} is down"
        ActionMailer::Base.deliveries.count.should == 1
      end

      it "does not send a downtime notification email if another check shows the app is up" do
        new_status_url = "http://www.foo.com"
        FakeWeb.register_uri(:get, new_status_url, [{status: ["200", "OK"], body: valid_body_string},
                                                    {status: ["500", "Internal Server Error"]},
                                                    {status: ["200", "OK"], body: valid_body_string}])
        application = FactoryGirl.create(:web_application_with_user, status_url: new_status_url)
        WebApplication.stub(:all).and_return([application])
        subject.invoke

        ActionMailer::Base.deliveries.count.should == 0
      end
    end

    context "a downtime notification has been sent" do
      it "does not send an email if an email has been sent less than an hour ago" do
        @web_app.update_attributes(last_downtime_notification_at: 3.minutes.ago)
        subject.invoke
        ActionMailer::Base.deliveries.count.should == 0
      end

      it "sends an email if an email has been sent more than an hour ago" do
          @web_app.update_attributes(last_downtime_notification_at: 62.minutes.ago)
          subject.invoke
          ActionMailer::Base.deliveries.first.subject == "#{@web_app.name} is down"
          ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end

  context "an application is up" do
    context "a downtime notification has not been sent" do
      it "does not send any emails" do
        subject.invoke
        ActionMailer::Base.deliveries.count.should == 0
      end
    end

    context "a downtime notification has been sent" do
      it "sends a recovery email" do
        @web_app.update_attributes(last_downtime_notification_at: 2.hours.ago)
        subject.invoke
        ActionMailer::Base.deliveries.first.subject == "#{@web_app.name} has recovered"
        ActionMailer::Base.deliveries.count.should == 1        
      end
    end
  end
end