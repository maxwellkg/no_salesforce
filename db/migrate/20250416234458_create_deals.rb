class CreateDeals < ActiveRecord::Migration[8.0]
  def change
    create_table :deals do |t|
      t.references :account, null: false, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.date :close_date, null: false
      t.references :stage, null: false, foreign_key: { to_table: :deal_stages }
      t.references :source, foreign_key: { to_table: :account_lead_sources }
      t.string :name, null: false
      t.text :description
      t.float :amount
      t.datetime :last_activity_at

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :last_updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
