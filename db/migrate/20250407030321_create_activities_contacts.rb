class CreateActivitiesContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :activities_contacts do |t|
      t.references :activity, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
