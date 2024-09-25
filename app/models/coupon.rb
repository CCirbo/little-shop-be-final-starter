class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, presence: { message: ": You must provide a coupon name." }
  validates :code, presence: true, uniqueness: { message: ": A unique coupon code is required." }
  validates :dollar_off, presence: false
  validates :percent_off, presence: false
  validates :active, presence: false


  def validate_coupon(merchant)
    if self.percent_off && self.dollar_off
      raise ArgumentError.new("You need to provide either percent_off or dollar_off")
    elsif !self.percent_off && !self.dollar_off
      raise ArgumentError.new("You need to provide either percent_off or dollar_off")
    else
      self
    end
    
    if merchant_active_coupon_count == 5 && self.active == true
      raise ArgumentError.new("Merchant can only have a maximum of five active coupons")
    end
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

