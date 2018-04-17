class RemoveAdminUsersTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :admins
  end
end
