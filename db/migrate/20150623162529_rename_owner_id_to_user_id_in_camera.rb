class RenameOwnerIdToUserIdInCamera < ActiveRecord::Migration
  def change
    rename_column :cameras, :owner_id, :user_id
  end
end
