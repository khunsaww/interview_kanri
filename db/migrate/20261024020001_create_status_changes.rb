class CreateStatusChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :status_changes do |t|
      t.references :job_application, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status, null: false
      t.date :changed_on, null: false

      t.timestamps
    end

    add_index :status_changes, [:job_application_id, :changed_on]
  end
end
