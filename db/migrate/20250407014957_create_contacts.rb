class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :email_address, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.references :phone_number
      t.datetime :last_activity_time
      t.references :lead_source, foreign_key: { to_table: :account_lead_sources }
      t.references :address, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.string :job_title
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :last_updated_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
