class CreateOpportunityStages < ActiveRecord::Migration[8.0]
  def change
    create_table :opportunity_stages do |t|
      t.string :name, null: false, unique: true
      
      t.timestamps
    end
  end
end
