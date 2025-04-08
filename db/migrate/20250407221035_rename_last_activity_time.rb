class RenameLastActivityTime < ActiveRecord::Migration[8.0]
  def change
    rename_column :accounts, :last_activity_time, :last_activity_at
    rename_column :contacts, :last_activity_time, :last_activity_at
  end
end
