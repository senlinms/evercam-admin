class RemovePasswordFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :admins, :password, :string
  end
end
