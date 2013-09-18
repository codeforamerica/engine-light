FactoryGirl.define do
  factory :web_application do
    sequence(:name) {|n| "web_application_#{n}" }
  end
end