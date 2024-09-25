require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  before(:each) do
  
    @merchant1 = Merchant.create!(name: "Merchant 1")
    @merchant2 = Merchant.create!(name: "Merchant 2")
    @coupon1 = @merchant1.coupons.create!(
      name: "BOGO",
      code: "BOGO25",
      dollar_off: nil,
      percent_off: 25.00,
      active: true,
      times_used: 0
    )
    @coupon2 = @merchant1.coupons.create!(
      name: "BOGO1",
      code: "BOGO250",
      dollar_off: 25.00,
      percent_off: nil,
      active: true,
      times_used: 0
    )
    @inactive_coupon = @merchant1.coupons.create!(
      name: "Inactive Coupon",
      code: "INACT1",
      dollar_off: nil,
      percent_off: 10.00,
      active: false,
      times_used: 0
    )
    @headers = { "CONTENT_TYPE" => "application/json" }
  end

  describe "Get all coupons for a merchant" do
    it "can return all coupons for a given merchant" do
      coupon_body = {
        name: "SAVEMORE",
        code: "Save25",
        dollar_off: nil,
        percent_off: 25.00,
        active: true,
        times_used: 0
      }
      post "/api/v1/merchants/#{@merchant1.id}/coupons", headers: @headers, params: JSON.generate(coupon_body)

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(json[:data].count).to eq(3)
    # require 'pry'; binding.pry
      expect(json[:data][:attributes]).to include(:name, :code, :active)
      expect(json[:data][:attributes][:name]).to eq("SAVEMORE")
      expect(json[:data][:attributes][:name]).to be_a(String)
      expect(json[:data][:attributes][:code]).to eq("Save25")
      expect(json[:data][:attributes][:code]).to be_a(String)
      expect(json[:data][:attributes][:dollar_off]).to eq(nil)
      expect(json[:data][:attributes][:percent_off]).to eq(25.00)
      expect(json[:data][:attributes][:percent_off]).to be_a(Float)
      expect(json[:data][:attributes][:active]).to eq(true)
      expect(json[:data][:attributes][:times_used]).to eq(0)
      expect(json[:data][:attributes][:times_used]).to be_an(Integer)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][:attributes][:merchant_id]).to be_a(Integer)
    end

    it "can return all coupons if no filter is passed" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(3)
    end

    it "can return an empty array when merchant has no coupons" do
      merchant = Merchant.create!(name: "Empty Merchant")

      get "/api/v1/merchants/#{merchant.id}/coupons"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to eq([])
    end
  end

  describe "Get a single coupon" do
    it "can return a single coupon with the correct attributes" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:name]).to eq("BOGO")
      expect(json[:data][:attributes][:code]).to eq("BOGO25")
      expect(json[:data][:attributes][:percent_off]).to eq(25.00)
      expect(json[:data][:attributes][:name]).to be_a(String)
      expect(json[:data][:attributes][:code]).to be_a(String)
      expect(json[:data][:attributes][:dollar_off]).to eq(nil)
      expect(json[:data][:attributes][:percent_off]).to be_a(Float)
      expect(json[:data][:attributes][:active]).to eq(true)
      expect(json[:data][:attributes][:times_used]).to eq(0)
      expect(json[:data][:attributes][:times_used]).to be_an(Integer)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  
  describe "Create a new coupon" do
    it "can create a coupon when valid attributes are given" do
      coupon_params = { name: "New Coupon", code: "NEW20", percent_off: 20.00, active: true }
# require 'pry'; binding.pry
      post "/api/v1/merchants/#{@merchant1.id}/coupons",  params: coupon_params
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:name]).to eq("New Coupon")
      expect(json[:data][:attributes][:code]).to eq("NEW20")
      expect(json[:data][:attributes][:percent_off]).to eq(20.00)
      expect(json[:data][:attributes][:name]).to be_a(String)
      expect(json[:data][:attributes][:code]).to be_a(String)
      expect(json[:data][:attributes][:dollar_off]).to eq(nil)
      expect(json[:data][:attributes][:percent_off]).to be_a(Float)
      expect(json[:data][:attributes][:active]).to eq(true)
      expect(json[:data][:attributes][:times_used]).to eq(0)
      expect(json[:data][:attributes][:times_used]).to be_an(Integer)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  describe "Get coupons by status" do
    it "can return only active coupons when 'status=active' is passed" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons?status=active"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(2) 
      json[:data].each do |coupon|
      expect(coupon[:attributes][:active]).to eq(true)
      end
    end

    it "can return only inactive coupons when 'status=inactive' is passed" do
      get "/api/v1/merchants/#{@merchant1.id}/coupons?status=inactive"
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data].count).to eq(1)
      expect(json[:data].first[:attributes][:active]).to be false
    end
  end

  describe "Change coupon status to activate or deactivate" do
    it "can activate the coupon when submitting the active endpoint" do
      patch "/api/v1/merchants/#{@merchant1.id}/coupons/#{@inactive_coupon.id}/activate", headers: @headers
      @inactive_coupon.update(active: true)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(json[:data][:attributes][:active]).to eq(true)
    end

    it "can deactivate the coupon when submitting the deactivate endpoint" do
      @coupon1.update(active: true)

      patch "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}/deactivate", headers: @headers

      json = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(json[:data][:attributes][:active]).to eq(false)
    end
  end

  describe "Update a coupon" do
    it "can update a coupon's attributes successfully" do
      updated_coupon_params = {
        name: "Updated BOGO",
        code: "BOGO50",
        percent_off: 50.00,
        active: false
      }

      patch "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}", headers: @headers, params: JSON.generate(updated_coupon_params)

      expect(response).to be_successful
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:name]).to eq("Updated BOGO")
      expect(json[:code]).to eq("BOGO50")
      expect(json[:percent_off]).to eq(50.00)
      expect(json[:active]).to eq(false)
    end

    it "returns an error when the coupon update fails" do
      invalid_coupon_params = {
        name: "", # Invalid name, triggers validation failure
        code: "BOGO50",
        percent_off: 50.00,
        active: false
      }

      patch "/api/v1/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}", headers: @headers, params: JSON.generate(invalid_coupon_params)

      expect(response.status).to eq(422)
      json = JSON.parse(response.body, symbolize_names: true)
      expect(json[:errors]).to include("Name : You must provide a coupon name.")
    end
  end

  describe "Errors on Params" do
    it "can return an error message if required name is missing" do
      invalid_coupon_params = { name: "", code: "BOGO25", active: true, dollar_off: nil,
      percent_off: 25.00, } 

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: invalid_coupon_params
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:errors].first).to eq( "Name : You must provide a coupon name.")
    end
 
    it "can return an error message if code name is not unique" do
      invalid_coupon_params = { name: "BOGO", code: "BOGO25", active: true, dollar_off: nil,
      percent_off: 25.00,  } 

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: invalid_coupon_params
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:errors].first).to eq("Code : A unique coupon code is required.")
    end

    it "can return an error message if both discount values are missing" do
      invalid_coupon_params = { name: "BOGO", code: "BOGO25", active: true, dollar_off: nil,
      percent_off: nil,  } 

      post "/api/v1/merchants/#{@merchant1.id}/coupons", params: invalid_coupon_params
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:errors].first).to eq("You need to provide either percent_off or dollar_off")
    end
  end
end