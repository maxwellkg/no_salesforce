class CreateReminderLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :reminder_links do |t|
      t.references :reminder, null: false
      t.references :reminder_subject, null: false

      t.timestamps
    end

    add_index :reminder_links, [:reminder_id, :reminder_subject_id], unique: true
  end
end
