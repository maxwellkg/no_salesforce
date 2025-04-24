class CreateStateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :state_regions do |t|
      t.string :country_short_code, null: false
      t.references :country, null: false, foreign_key: true
      t.string :name
      t.references :type, foreign_key: { to_table: :state_region_types }
      t.string :alpha_code, null: false
      t.string :numeric_code, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
