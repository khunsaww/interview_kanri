class CreatePreparationTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :preparation_tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :job_application, null: false, foreign_key: true
      t.references :interview, foreign_key: true
      t.string :category, null: false
      t.string :title, null: false
      t.date :due_on
      t.text :memo
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at
      t.boolean :sample, null: false, default: false

      t.timestamps
    end

    add_index :preparation_tasks, [:user_id, :completed]
    add_index :preparation_tasks, :due_on
    add_index :preparation_tasks, :sample
  end
end
