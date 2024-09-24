FactoryBot.define do
    factory :invoice_item do
      quantity { 1 }  
      unit_price { 100.0 }  
      invoice  
      item  
    end
  end