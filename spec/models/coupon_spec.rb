require 'rails_helper'

RSpec.configure do |config| 
 config.formatter = :documentation 
 end

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:code)}
    it { should validate_presence_of(:active)}
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many(:invoices)}
  end
end
