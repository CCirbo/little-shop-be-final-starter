require "rails_helper"

RSpec.describe Invoice, type: :model do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  describe 'Total_without_discount' do
    it 'calculates the total without a discount applied' do
      merchant = create(:merchant)
      invoice = create(:invoice, merchant: merchant)
      item = create(:item, merchant: merchant)
      create(:invoice_item, invoice: invoice, item: item, quantity: 2, unit_price: 50.0)  

      expect(invoice.total_without_discount).to eq(100.0)
    end
  end

  describe 'Apply_coupon' do
    it 'applies a percent-off coupon to the total' do
      merchant = create(:merchant)
      invoice = create(:invoice, merchant: merchant)
      item = create(:item, merchant: merchant)  
      create(:invoice_item, invoice: invoice, item: item, quantity: 1, unit_price: 100.0)  
      coupon = create(:coupon, merchant: merchant, percent_off: 20, dollar_off: nil)  

      expect(invoice.apply_coupon(coupon)).to eq((invoice.total_without_discount * 0.8).round(2))
    end
  
    it 'applies a dollar-off coupon to the total' do
      merchant = create(:merchant)
      invoice = create(:invoice, merchant: merchant)
      item = create(:item, merchant: merchant) 
      create(:invoice_item, invoice: invoice, item: item, quantity: 1, unit_price: 50.0) 
      coupon = create(:coupon, merchant: merchant, dollar_off: 10, percent_off: nil)  

      expect(invoice.apply_coupon(coupon)).to eq(([invoice.total_without_discount - 10, 0].max).round(2))
    end
   
    it 'sets the total to $0 if the dollar-off coupon exceeds the total' do
      merchant = create(:merchant)
      invoice = create(:invoice, merchant: merchant)
      item = create(:item, merchant: merchant)  
      create(:invoice_item, invoice: invoice, item: item, quantity: 1, unit_price: 5.0) 
      coupon = create(:coupon, merchant: merchant, dollar_off: 10, percent_off: nil)  
      
      expect(invoice.apply_coupon(coupon)).to eq(0)
    end
  end
end
