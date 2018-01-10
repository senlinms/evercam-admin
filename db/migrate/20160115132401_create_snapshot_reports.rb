class CreateSnapshotReports < ActiveRecord::Migration[4.2]
  def change
    create_table :snapshot_reports do |t|

      t.timestamps null: false
    end
  end
end
