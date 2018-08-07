class AddMissingUrls < ActiveRecord::Migration[4.2]
  def self.up
    change_table(:vendor_models) do |t|
      t.string :mpeg4_url, default: ''
      t.string :mobile_url, default: ''
      t.string :lowres_url, default: ''
    end

    change_column_null :vendor_models, :h264_url, true
    change_column_null :vendor_models, :mjpg_url, true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
