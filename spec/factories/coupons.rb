FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    sequence(:code) { |n| "CODE#{n}" }
    dollar_off { 1.5 }
    percent_off { 1.5 }
    active { false }
    association :merchant
  end
end
