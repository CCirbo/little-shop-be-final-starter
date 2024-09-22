class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, presence: true
  validates :code, presence: true
  validates :dollar_off, presence: false
  validates :percent_off, presence: false
  validates :active, presence: true


  def validate_coupon
    if self.percent_off == nil && self.dollar_off == nil
      #msg you need percent off or dollar off change the errors: msg  status: 400 or 404
      return render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    else 
      return self
    end
  end

  def activate_or_deactivate(status)
    if status == "activate"
      self.active = true
    elsif status == "deactivate"
      self.active = false
    end
  end
end
