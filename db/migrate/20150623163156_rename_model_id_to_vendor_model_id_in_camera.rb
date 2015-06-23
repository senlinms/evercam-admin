class RenameModelIdToVendorModelIdInCamera < ActiveRecord::Migration
  def change
    rename_column :cameras, :model_id, :vendor_model_id
  end
end
