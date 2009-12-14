class AddProductGroupsToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :promoted_id,   :integer
    add_column :coupons, :promoted_type, :string
    add_column :coupons, :zone_id,       :integer
  end

  def self.down
  end
end