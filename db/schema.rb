# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_10_24_020003) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "interviews", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_application_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.string "format", default: "online", null: false
    t.string "round_name", null: false
    t.string "interviewer"
    t.string "meeting_url"
    t.string "place"
    t.integer "remind_minutes_before"
    t.text "memo"
    t.boolean "sample", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id"], name: "index_interviews_on_job_application_id"
    t.index ["sample"], name: "index_interviews_on_sample"
    t.index ["starts_at"], name: "index_interviews_on_starts_at"
  end

  create_table "job_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "company_name", null: false
    t.string "job_title", null: false
    t.date "applied_on"
    t.string "job_url"
    t.string "location"
    t.string "contact_name"
    t.string "contact_info"
    t.text "memo"
    t.string "status", default: "interested", null: false
    t.string "next_action"
    t.date "next_action_on"
    t.boolean "sample", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "applied_on"], name: "index_job_applications_on_user_id_and_applied_on"
    t.index ["user_id", "sample"], name: "index_job_applications_on_user_id_and_sample"
    t.index ["user_id", "status"], name: "index_job_applications_on_user_id_and_status"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "preparation_tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_application_id", null: false
    t.bigint "interview_id"
    t.string "category", null: false
    t.string "title", null: false
    t.date "due_on"
    t.text "memo"
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.boolean "sample", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_on"], name: "index_preparation_tasks_on_due_on"
    t.index ["interview_id"], name: "index_preparation_tasks_on_interview_id"
    t.index ["job_application_id"], name: "index_preparation_tasks_on_job_application_id"
    t.index ["sample"], name: "index_preparation_tasks_on_sample"
    t.index ["user_id", "completed"], name: "index_preparation_tasks_on_user_id_and_completed"
    t.index ["user_id"], name: "index_preparation_tasks_on_user_id"
  end

  create_table "status_changes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_application_id", null: false
    t.string "from_status"
    t.string "to_status", null: false
    t.date "changed_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_application_id", "changed_on"], name: "index_status_changes_on_job_application_id_and_changed_on"
    t.index ["job_application_id"], name: "index_status_changes_on_job_application_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "interviews", "job_applications"
  add_foreign_key "job_applications", "users"
  add_foreign_key "preparation_tasks", "interviews"
  add_foreign_key "preparation_tasks", "job_applications"
  add_foreign_key "preparation_tasks", "users"
  add_foreign_key "status_changes", "job_applications"
end
