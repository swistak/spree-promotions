class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.column :name,          :string
      t.column :description,   :text
      t.column :start_at,      :timestamp
      t.column :end_at,        :timestamp
      t.column :zone_id,       :integer
      t.column :promoted_id,   :integer
      t.column :promoted_type, :string
      t.column :combine,       :boolean
      t.column :usage_limit,   :integer
      t.column :type,          :string
      
      t.timestamps
    end

    create_table :promotions_users, :id => false do |t|
      t.column :user_id,      :integer
      t.column :promotion_id, :integer
    end

    add_index :promotions, [:promoted_id, :promoted_type]
    add_index :promotions, [:promoted_type, :promoted_id]
    add_index :promotions, :name
    add_index :promotions, :zone_id

    add_index :promotions_users, :user_id
    add_index :promotions_users, :promotion_id
  end

  def self.down
  end
end
