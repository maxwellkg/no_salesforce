class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :alpha_2, null: false, index: { unique: true }
      t.string :alpha_3, null: false, index: { unique: true }
      t.string :country_code, null: false, index: { unique: true }
      t.string :iso_3166__2, null: false, index: { unique: true }
      t.string :region
      t.string :sub_region
      t.string :intermediate_region
      t.string :region_code
      t.string :sub_region_code
      t.string :intermediate_region_code

      t.timestamps
    end
  end
end
