class CreateCameraShares < ActiveRecord::Migration
  def change
    create_table :camera_shares do |t|
      t.belongs_to :camera, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false
      t.integer :sharer_id
      t.string :kind, limit: 50, null: false

      t.timestamps null: false
    end
  end
end