class CreateReminderSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :reminder_subjects do |t|
      t.text :name, null: false
      t.references :source, polymorphic: true, null: false

      t.timestamps
    end
  end
end
