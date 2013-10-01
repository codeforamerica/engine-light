FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "test_user#{n}@cfa.org" }
  end

  factory :user_with_web_application, parent: :user do
    after :create do |user|
      user.web_applications = FactoryGirl.create_list(:web_application, 1)
    end
  end

  factory :web_application do
    sequence(:name) {|n| "web_application_#{n}" }
    status_url "http://www.codeforamerica.org/.well-known/status"
  end

  factory :web_application_with_user, parent: :web_application do
    after :create do |web_app|
      web_app.users = FactoryGirl.create_list(:user, 1)
    end
  end
end