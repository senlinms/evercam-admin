class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :exid, null: false
      t.string :name, null: false
      t.string :known_macs, null: false, array: true

      t.timestamps null: false
    end
  end
end
