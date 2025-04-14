class CreateAccountLeadSources < ActiveRecord::Migration[8.0]
  def change
    create_table :account_lead_sources do |t|
      t.text :name, null: false, index: { unique: true }
      
      t.timestamps
    end
  end
end
