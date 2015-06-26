class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :notes
      t.integer :camera_id, index: true, foreign_key: true, null: false
      t.binary :data, null: false
      t.boolean :is_public, null: false, default: false

      t.timestamps null: false
    end
  end
end
