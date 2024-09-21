FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    dollar_off { 1.5 }
    percent_off { 1.5 }
    active { false }
    association :merchant
  end
end
