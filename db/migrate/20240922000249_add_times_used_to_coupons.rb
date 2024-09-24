class AddTimesUsedToCoupons < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :times_used, :integer, default: 0
  end
end
