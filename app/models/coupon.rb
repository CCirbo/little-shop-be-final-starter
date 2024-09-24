class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, presence: true
  validates :code, presence: true
  validates :dollar_off, presence: false
  validates :percent_off, presence: false
  validates :active, presence: false


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
    if merchant_active_coupon_count == 5 && self.active == true
      raise ArgumentError.new("Merchant can only have a maximum of five active coupons")
    end
   
     # code validator
    # check all coupons and validate code uniqueness
    if Coupon.exists?(code: self.code)
      raise ArgumentError.new("Coupon code must be unique")
    end
    # require 'pry'; binding.pry
    # get merchant.invoice?? 
    # if coupon drops invoice below zero dollar amount it needs to be set to zero

    # A coupon code from a Merchant only applies to Items sold by that Merchant. Get
    # invoice with the coupon and make sure the merchant id is the same or return an 
    # error
  end
   

  def merchant_active_coupon_count
    Coupon.where({ merchant_id: merchant.id, active:true }).count
  end

  def activate_or_deactivate(status)
    if status == "activate" && merchant_active_coupon_count == 5
      raise ArgumentError.new("Merchant can only have a maximum of five active coupons")
    elsif status == "activate" 
      self.active = true
    elsif status == "deactivate"
      self.active = false
    end
  end
end

