class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, presence: true
  validates :code, presence: true
  validates :dollar_off, presence: true
  validates :percent_off, presence: true
  validates :active, presence: true
end
