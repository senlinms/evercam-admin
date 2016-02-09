class CreateSnapshotExtractors < ActiveRecord::Migration
  def change
    create_table :snapshot_extractors do |t|

      t.timestamps null: false
    end
  end
end
