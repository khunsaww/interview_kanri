class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :company_name, null: false
      t.string :job_title, null: false
      t.date :applied_on
      t.string :job_url
      t.string :location
      t.string :contact_name
      t.string :contact_info
      t.text :memo
      t.string :status, null: false, default: "interested"
      t.string :next_action
      t.date :next_action_on
      t.boolean :sample, null: false, default: false

      t.timestamps
    end

    add_index :job_applications, [:user_id, :status]
    add_index :job_applications, [:user_id, :applied_on]
    add_index :job_applications, [:user_id, :sample]
  end
end
