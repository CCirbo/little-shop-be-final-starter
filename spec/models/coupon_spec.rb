require 'rails_helper'

RSpec.configure do |config| 
 config.formatter = :documentation 
 end

RSpec.describe Coupon, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:name).with_message(": You must provide a coupon name.") }
    it { should validate_presence_of(:code) }
  end

  describe 'Relationships' do
    it { should belong_to :merchant }
    it { should have_many(:invoices)}
  end

  describe 'Validate_coupon method' do
    it 'raises an error if both percent_off and dollar_off are provided' do
      merchant = create(:merchant)
      coupon = Coupon.new(name: "Test Coupon", code: "TEST10", percent_off: 10, dollar_off: 5, merchant: merchant)
  
      expect { coupon.validate_coupon(merchant) }.to raise_error(ArgumentError, "You need to provide either percent_off or dollar_off")
    end
  
    it 'Raises an error if neither percent_off nor dollar_off is provided' do
      merchant = create(:merchant)
      coupon = Coupon.new(name: "Test Coupon", code: "TEST10", merchant: merchant)
  
      expect { coupon.validate_coupon(merchant) }.to raise_error(ArgumentError, "You need to provide either percent_off or dollar_off")
    end
  
    it 'Does not raise an error if only percent_off is provided' do
      merchant = create(:merchant)
      coupon = Coupon.new(name: "Test Coupon", code: "TEST10", percent_off: 10, merchant: merchant)
  
      expect { coupon.validate_coupon(merchant) }.not_to raise_error
    end
  
    it 'Does not raise an error if only dollar_off is provided' do
      merchant = create(:merchant)
      coupon = Coupon.new(name: "Test Coupon", code: "TEST10", dollar_off: 5, merchant: merchant)
  
      expect { coupon.validate_coupon(merchant) }.not_to raise_error
    end
  end

  describe 'Active coupon limit' do
    it 'raises an error if merchant has 5 active coupons and tries to activate another one' do
      merchant = create(:merchant)
      5.times { create(:coupon, merchant: merchant, active: true) }
      new_coupon = Coupon.new(name: "Test Coupon", code: "TEST10", dollar_off: 5, merchant: merchant, active: true)

      expect { new_coupon.validate_coupon(merchant) }.to raise_error(ArgumentError, "Merchant can only have a maximum of five active coupons")
    end
  end

  describe 'Activate_or_deactivate method' do
    it 'activates the coupon if the merchant has less than 5 active coupons' do
      merchant = create(:merchant)
      coupon = create(:coupon, active: false, merchant: merchant)
      coupon.activate_or_deactivate("activate")
  
      expect(coupon.active).to eq(true)
    end
  
    it 'deactivates the coupon' do
      merchant = create(:merchant)
      coupon = create(:coupon, active: true, merchant: merchant)
      coupon.activate_or_deactivate("deactivate")
  
      expect(coupon.active).to eq(false)
    end
  
    it 'raises an error if trying to activate a coupon when the merchant has 5 active coupons' do
      merchant = create(:merchant)
      5.times { create(:coupon, merchant: merchant, active: true) }
      coupon = create(:coupon, active: false, merchant: merchant)
  
      expect { coupon.activate_or_deactivate("activate") }.to raise_error(ArgumentError, "Merchant can only have a maximum of five active coupons")
    end
  end

  describe 'Coupon code uniqueness' do
    it 'raises an error if a coupon with the same code already exists' do
      merchant = create(:merchant)
      create(:coupon, code: "TEST10", merchant: merchant)
      expect { 
        Coupon.create!(name: "Test Coupon", code: "TEST10", percent_off: 10, merchant: merchant) 
      }.to raise_error(ActiveRecord::RecordInvalid, /Code : A unique coupon code is required/)
    end
  end
end
