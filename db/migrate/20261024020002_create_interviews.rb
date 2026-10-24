class CreateInterviews < ActiveRecord::Migration[7.1]
  def change
    create_table :interviews do |t|
      t.references :job_application, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.string :format, null: false, default: "online"
      t.string :round_name, null: false
      t.string :interviewer
      t.string :meeting_url
      t.string :place
      t.integer :remind_minutes_before
      t.text :memo
      t.boolean :sample, null: false, default: false

      t.timestamps
    end

    add_index :interviews, :starts_at
    add_index :interviews, :sample
  end
end
