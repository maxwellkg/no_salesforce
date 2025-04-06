class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :parent, foreign_key: { to_table: :accounts }
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :billing_address, foreign_key: { to_table: :addresses }
      t.references :shipping_address, foreign_key: { to_table: :addresses }
      t.references :phone_number, foreign_key: true
      t.text :description
      t.integer :annual_revenue
      t.integer :number_of_employees
      t.references :industry, foreign_key: true
      t.string :website
      t.date :incorporation_date
      t.references :account_source, foreign_key: true
      t.datetime :last_activity_time
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :last_updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
