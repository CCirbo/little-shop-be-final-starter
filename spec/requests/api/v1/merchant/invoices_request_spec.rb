require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
  before :each do
    @merchant2 = create(:merchant)
    @merchant1 = create(:merchant)

    @customer1 = create(:customer)
    @customer2 = create(:customer)

    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged")
    create_list(:invoice, 3, merchant_id: @merchant1.id, customer_id: @customer1.id) # shipped by default
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")
    @coupon1 = @merchant1.coupons.create!(
      name: "BOGO",
      code: "BOGO25",
      dollar_off: nil,
      percent_off: 25.00,
      active: true,
      times_used: 0
    )
  end

  it "should return all invoices for a given merchant based on status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
    expect(json[:data][0][:type]).to eq("invoice")
    expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
    expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
    expect(json[:data][0][:attributes][:status]).to eq("packaged")
  end

  it "should get multiple invoices if they exist for a given merchant and status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(3)
  end

  it "should only get invoices for merchant given" do
    get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice2.id.to_s)
  end

  it "should return 404 and error message when merchant is not found" do
    get "/api/v1/merchants/100000/customers"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:message]).to eq("Your query could not be completed")
    expect(json[:errors]).to be_a Array
    expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
  end

  it "should return error if coupon does not belong to merchant and returns error if applying multiple coupons to an invoice" do
    coupon3 = @merchant2.coupons.create!(
      name: "BOGO1",
      code: "BOGO2501",
      dollar_off: 25.00,
      percent_off: nil,
      active: true,
      times_used: 0
    )
    coupon2 = @merchant2.coupons.create!(
      name: "BOGO1",
      code: "BOGO250",
      dollar_off: 25.00,
      percent_off: nil,
      active: true,
      times_used: 0
    )
    @invoice2.apply_coupon(coupon2)
    expect{ @invoice2.apply_coupon(coupon3) }.to raise_error(ArgumentError, "Invoice can only have one coupon") 
    expect{ @invoice1.apply_coupon(coupon3) }.to raise_error(ArgumentError, "Coupon is invalid for this merchant") 
    expect(@invoice1.apply_coupon(@coupon1)).to eq(0.0) 
  end

  it "should return error if coupon does not belong to merchant and returns error if applying multiple coupons to an invoice" do
    coupon3 = @merchant2.coupons.create!(
      name: "BOGO1",
      code: "BOGO2501",
      dollar_off: 25.00,
      percent_off: nil,
      active: true,
      times_used: 0
    )
    coupon2 = @merchant2.coupons.create!(
      name: "BOGO1",
      code: "BOGO250",
      dollar_off: 25.00,
      percent_off: nil,
      active: true,
      times_used: 0
    )
    get "/api/v1/merchants/#{@merchant2.id}/invoices"
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data][0][:attributes][:coupon_id]).to eq(nil)
    @invoice2.apply_coupon(coupon2)
    get "/api/v1/merchants/#{@merchant2.id}/invoices"
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:data][0][:attributes][:coupon_id]).to eq(coupon2.id)
  end
end