class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, presence: true
  validates :code, presence: true
  validates :dollar_off, presence: false
  validates :percent_off, presence: false
  validates :active, presence: true


  def validate_coupon(merchant)
# find the merchant
# require 'pry'; binding.pry
    # dollar_or_percent_off_validator
    if self.percent_off && self.dollar_off
      raise ArgumentError.new("You need to provide either percent_off or dollar_off")
    elsif !self.percent_off && !self.dollar_off
      raise ArgumentError.new("You need to provide either percent_off or dollar_off")
    else
      self
    end
    
    # get count of all of merchant's coupons
    if merchant_active_coupon_count == 5
      raise ArgumentError.new("Merchant can only have a maximum of five active coupons")
    end
    # return true if merchant coupon.count is less than 5
    # return false if coupon.count is 5 or greater

    # name validator
    # check all merchant coupons and validate uniqueness

    # code validator
    # check all coupons and validate code uniqueness
  end

  def merchant_active_coupon_count
    Coupon.where({ merchant_id: merchant.id, active:true }).count
  end


  


  def activate_or_deactivate(status)
    if status == "activate" && merchant_active_coupon_count >= 5
    elsif status == "activate" 
      self.active = true
    elsif status == "deactivate"
      self.active = false
    end
  end
end

# def validate_coupon
#   if self.percent_off == nil && self.dollar_off == nil
#     #msg you need percent off or dollar off change the errors: msg  status: 400 or 404
#     return render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
#   else 
#     return self
#   end
# end