class CreateVendorModels < ActiveRecord::Migration
  def change
    create_table :vendor_models do |t|
      t.belongs_to :vendor, index: true, foreign_key: true
      t.string :name, null: false
      t.json :config, null: false
      t.string :exid, default: "", null: false
      t.string :jpg_url, default: "", null: false
      t.string :h264_url, default: "", null: false
      t.string :mjpg_url, default: "", null: false

      t.timestamps null: false
    end
  end
end
