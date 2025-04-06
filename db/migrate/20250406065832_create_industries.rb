class CreateIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :industries do |t|
      t.timestamps
    end
  end
end
