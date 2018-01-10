class CreateCountries < ActiveRecord::Migration[4.2]
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.string :iso3166_a2, null: false

      t.timestamps null: false
    end
  end
end
