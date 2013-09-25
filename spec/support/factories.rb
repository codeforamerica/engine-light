FactoryGirl.define do
  factory :web_application do
    sequence(:name) {|n| "web_application_#{n}" }
    status_url "http://www.codeforamerica.org/.well-known/status"
  end

  factory :user do
    sequence(:email) {|n| "test_user{n}@cfa.org" }
  end
end