class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :coupon, optional: true
  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

  def apply_coupon(coupon = nil)
    # require 'pry'; binding.pry
    return total_without_discount(coupon) unless coupon
    raise ArgumentError.new("Coupon is invalid for this merchant") unless coupon.merchant_id == merchant_id
    raise ArgumentError.new("Invoice can only have one coupon") if self.coupon_id
    discounted_total = if coupon.percent_off
                         total_without_discount(coupon) - (total_without_discount(coupon) * coupon.percent_off / 100.0)

                       elsif coupon.dollar_off
                         total_without_discount(coupon) - coupon.dollar_off
                       end

    [discounted_total, 0].max.round(2)
  end

  def total_without_discount(coupon = nil)
   if coupon
    self.coupon_id = coupon.id
    self.save
   end
    invoice_items.sum { |item| item.unit_price * item.quantity }.round(2)
  end
end