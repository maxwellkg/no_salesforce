class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :account, null: false, foreign_key: true
      t.datetime :occurring_at, null: false
      t.references :type, null: false, foreign_key: { to_table: :activity_types }
      t.text :title, null: false
      t.boolean :complete, null: false, default: false

      t.references :logged_to, null: false, polymorphic: true

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :last_updated_by, foreign_key: { to_table: :users }

      t.references :assigned_to, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
