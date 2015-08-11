class CreateCameras < ActiveRecord::Migration
  def change
    create_table :cameras do |t|
      t.string :exid, null: false
      t.integer :owner_id, null: false
      t.boolean :is_public, null: false
      t.json :config, null: false
      t.string :name, null: false
      t.datetime :last_polled_at
      t.boolean :is_online
      t.string :timezone
      t.datetime :last_online_at
      t.text :location
      t.macaddr :mac_address
      t.integer :model_id
      t.boolean :discoverable, null: false, default: false
      t.binary :preview
      t.string :thumbnail_url

      t.timestamps null: false
    end
  end
end
