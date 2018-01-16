class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :admins do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :username, null: false
      t.string :password, null: false
      t.belongs_to :country, index: true, foreign_key: true
      t.datetime :confirmed_at
      t.string :email, null: false
      t.string :reset_token
      t.datetime :token_expires_at
      t.string :api_id
      t.string :api_key
      t.boolean :is_admin, null: false, default: false
      t.string :stripe_customer_id

      t.timestamps null: false
    end
  end
end
