class CreateStateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :state_regions do |t|
      t.string :country_short_code, null: false
      t.references :country, null: false, foreign_key: true
      t.string :name
      t.references :state_region_type, foreign_key: true
      t.string :alpha_code, null: false
      t.string :numeric_code, null: false

      t.timestamps
    end
  end
end
