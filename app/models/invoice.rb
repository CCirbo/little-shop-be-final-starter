class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  belongs_to :coupon, optional: true
  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

  def apply_coupon
    return total_without_discount unless coupon

    # Ensure the coupon belongs to the correct merchant
    raise ArgumentError.new("Coupon is invalid for this merchant") unless coupon.merchant_id == merchant_id

    # Apply percent-off or dollar-off discount
    discounted_total = if coupon.percent_off
                         total_without_discount - (total_without_discount * coupon.percent_off / 100.0)
                       elsif coupon.dollar_off
                         total_without_discount - coupon.dollar_off
                       else
                         total_without_discount
                       end

    # Ensure the total doesn't drop below 0, and round to two decimal places
    [discounted_total, 0].max.round(2)
  end

  def total_without_discount
    # Sum up all invoice items and ensure it's rounded to two decimal places
    invoice_items.sum { |item| item.unit_price * item.quantity }.round(2)
  end
end