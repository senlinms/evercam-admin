class CreateSnapshotReports < ActiveRecord::Migration
  def change
    create_table :snapshot_reports do |t|

      t.timestamps null: false
    end
  end
end
