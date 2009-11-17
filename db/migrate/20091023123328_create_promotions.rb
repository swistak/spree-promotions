class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :start_at, :timestamp
      t.column :end_at, :timestamp
      t.column :zone_id, :integer
      t.column :promoted_id, :integer
      t.column :promoted_type, :string
      t.column :combine, :boolean
      
      t.timestamps
    end

    add_index :promotions, [:promoted_id, :promoted_type]
    add_index :promotions, :name
    add_index :promotions, :zone_id
  end

  def self.down
  end
end
