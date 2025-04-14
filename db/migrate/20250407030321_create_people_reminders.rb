class CreatePeopleReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :people_reminders do |t|
      t.references :reminder, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
  end
end
