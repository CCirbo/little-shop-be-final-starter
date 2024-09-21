class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.float :dollar_off
      t.float :percent_off
      t.boolean :active 
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
