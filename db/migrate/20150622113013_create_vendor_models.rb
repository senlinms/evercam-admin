class CreateVendorModels < ActiveRecord::Migration
  def change
    create_table :vendor_models do |t|
      t.belongs_to :vendor, index: true, foreign_key: true
      t.string :name, null: false
      t.json :config, null: false
      t.string :exid,  null: false
      t.string :jpg_url, null: false
      t.string :h264_url, null: false
      t.string :mjpg_url, null: false

      t.timestamps null: false
    end
  end
end
