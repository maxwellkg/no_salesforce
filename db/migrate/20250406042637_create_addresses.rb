class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.text :street
      t.text :city
      t.references :state_region, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.text :postal_code

      t.timestamps
    end
  end
end
