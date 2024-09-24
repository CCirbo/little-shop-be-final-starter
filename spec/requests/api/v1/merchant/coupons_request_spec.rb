require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  it "should return all coupons for a given merchant" do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)
    # create(:item, merchant_id: merchant2.id)
    coupon1 = merchant1.coupons.create({
      name: "BOGO",
      code: "BOGO25",
      percent_off: 25.00,
      active: "active"
      })
     coupon2 = merchant1.coupons.create({
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
# require 'pry'; binding.pry
    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    # expect(json[:data].count).to eq(3)
    # expect(json[:data][0][:id]).to eq(item1.id.to_s)
    # expect(json[:data][1][:id]).to eq(item2.id.to_s)
    # expect(json[:data][2][:id]).to eq(item3.id.to_s)
  end

#   it "should return 404 and error message when merchant is not found" do
#     get "/api/v1/merchants/100000/items"

#     json = JSON.parse(response.body, symbolize_names: true)

#     expect(response).to have_http_status(:not_found)
#     expect(json[:message]).to eq("Your query could not be completed")
#     expect(json[:errors]).to be_a Array
#     expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
#   end
end