class CreatePhoneNumbers < ActiveRecord::Migration[8.0]
  def change
    create_table :phone_numbers do |t|
      t.references :country, foreign_key: true
      t.string :number, null: false

      t.timestamps
    end
  end
end
