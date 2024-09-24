require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  describe "Get all coupons for a merchant" do
    it "should return all coupons for a given merchant" do
      Merchant.destroy_all
      Coupon.destroy_all
      merchant1 = Merchant.create!(name: "Merchant 1")
      merchant2 = Merchant.create!(name: "Merchant 2")
  
      coupon1 = merchant1.coupons.create!({
        name: "BOGO",
        code: "BOGO25",
        percent_off: 25.00,
        active: "active"
        })
      coupon2 = merchant1.coupons.create!({
          name: "BOGO1",
          code: "BOGO250",
          dollar_off: 25.00,
          active: "active"
          })
      coupon_body = {
          name: "SAVEMORE ",
          code: "Save25",
          percent_off: 25.00,
          active: "active"
          }
      headers = {"CONTENT_TYPE" => "application/json"}
      post "/api/v1/merchants/#{merchant1.id}/coupons", headers: headers, params: JSON.generate(coupon_body)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      # expect(json[:data].count).to eq(2)
      # expect(json[:data].first[:attributes]).to include(:name, :code, :active)
    end

    it "should return an empty array when merchant has no coupons" do
      merchant = Merchant.create!(name: "Empty Merchant")
      
      get "/api/v1/merchants/#{merchant.id}/coupons"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to eq([])
    end
  end

  describe "Get a single coupon" do
    it "should return a single coupon with the correct attributes" do
      merchant = Merchant.create!(name: "Merchant 1")
      coupon = merchant.coupons.create!(name: "Discount", code: "DISC10", dollar_off: 10.00, active: true)

      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:name]).to eq("Discount")
      expect(json[:data][:attributes][:code]).to eq("DISC10")
      expect(json[:data][:attributes][:dollar_off]).to eq(10.00)
    end
  end
  
  describe "Create a new coupon" do
    it "should successfully create a coupon when valid attributes are provided" do
      merchant = Merchant.create!(name: "Merchant 1")
      coupon_params = { name: "New Coupon", code: "NEW20", percent_off: 20.00, active: true }

      post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:name]).to eq("New Coupon")
      expect(json[:data][:attributes][:code]).to eq("NEW20")
      expect(json[:data][:attributes][:percent_off]).to eq(20.00)
    end
  end

  # it "should return an error message if required attributes are missing" do
  #   merchant = Merchant.create!(name: "Merchant 1")
  #   invalid_coupon_params = { code: "INVALID", active: true } # Missing 'name' and discount

  #   post "/api/v1/merchants/#{merchant.id}/coupons", params: invalid_coupon_params
  #   json = JSON.parse(response.body, symbolize_names: true)

  #   expect(json[:errors].first).to eq("Validation failed: Name can't be blank")
  # end



end