class RemoveAccountAndLoggedToFromReminders < ActiveRecord::Migration[8.0]
  def change
    remove_reference :reminders, :account
    remove_reference :reminders, :logged_to, polymorphic: true

    drop_table :people_reminders
  end
end
