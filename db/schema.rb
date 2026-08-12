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

ActiveRecord::Schema[8.1].define(version: 2026_08_10_162000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "email_consent", default: false, null: false
    t.datetime "email_consent_at"
    t.string "email_consent_source"
    t.string "name"
    t.string "phone"
    t.boolean "sms_consent", default: false, null: false
    t.datetime "sms_consent_at"
    t.string "sms_consent_source"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "index_contacts_on_tenant_id_and_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["tenant_id", "phone"], name: "index_contacts_on_tenant_id_and_phone", unique: true, where: "(phone IS NOT NULL)"
    t.index ["tenant_id"], name: "index_contacts_on_tenant_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "accepted_at", null: false
    t.string "anonymous_id"
    t.boolean "bot", default: false, null: false
    t.datetime "created_at", null: false
    t.string "device_class", default: "unknown", null: false
    t.string "event_id", null: false
    t.string "event_type", null: false
    t.boolean "internal", default: false, null: false
    t.text "landing_page", default: "unknown", null: false
    t.bigint "location_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.text "page_url", null: false
    t.text "referrer", default: "unknown", null: false
    t.string "request_id", null: false
    t.string "session_id", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "utm_campaign", default: "unknown", null: false
    t.string "utm_content", default: "unknown", null: false
    t.string "utm_medium", default: "unknown", null: false
    t.string "utm_source", default: "unknown", null: false
    t.string "utm_term", default: "unknown", null: false
    t.bigint "website_id", null: false
    t.index ["location_id"], name: "index_events_on_location_id"
    t.index ["tenant_id", "event_id"], name: "index_events_on_tenant_id_and_event_id", unique: true
    t.index ["tenant_id", "event_type", "occurred_at"], name: "index_events_on_tenant_id_and_event_type_and_occurred_at"
    t.index ["tenant_id", "location_id", "occurred_at"], name: "index_events_on_tenant_id_and_location_id_and_occurred_at"
    t.index ["tenant_id", "occurred_at"], name: "index_events_on_tenant_id_and_occurred_at"
    t.index ["tenant_id", "session_id", "occurred_at"], name: "index_events_on_tenant_id_and_session_id_and_occurred_at"
    t.index ["tenant_id"], name: "index_events_on_tenant_id"
    t.index ["website_id"], name: "index_events_on_website_id"
  end

  create_table "job_applicants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "phone"
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "email"], name: "index_job_applicants_on_tenant_id_and_email", unique: true
    t.index ["tenant_id"], name: "index_job_applicants_on_tenant_id"
  end

  create_table "job_application_histories", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "change_type", null: false
    t.datetime "created_at", null: false
    t.string "from_status"
    t.bigint "job_application_id", null: false
    t.text "note"
    t.datetime "occurred_at", null: false
    t.bigint "tenant_id", null: false
    t.string "to_status"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_job_application_histories_on_actor_id"
    t.index ["job_application_id"], name: "index_job_application_histories_on_job_application_id"
    t.index ["tenant_id", "job_application_id", "occurred_at"], name: "index_job_application_histories_on_tenant_application_time"
    t.index ["tenant_id"], name: "index_job_application_histories_on_tenant_id"
  end

  create_table "job_applications", force: :cascade do |t|
    t.text "availability"
    t.datetime "created_at", null: false
    t.text "experience"
    t.boolean "future_opportunities_consent", default: false, null: false
    t.string "idempotency_key", null: false
    t.bigint "job_applicant_id", null: false
    t.bigint "job_posting_id", null: false
    t.bigint "location_id"
    t.text "motivation"
    t.datetime "occurred_at", null: false
    t.text "page_url", default: "unknown", null: false
    t.string "privacy_notice_version", null: false
    t.string "request_id", null: false
    t.string "source", default: "unknown", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "website_id", null: false
    t.index ["job_applicant_id"], name: "index_job_applications_on_job_applicant_id"
    t.index ["job_posting_id"], name: "index_job_applications_on_job_posting_id"
    t.index ["location_id"], name: "index_job_applications_on_location_id"
    t.index ["tenant_id", "idempotency_key"], name: "index_job_applications_on_tenant_id_and_idempotency_key", unique: true
    t.index ["tenant_id", "location_id", "created_at"], name: "idx_on_tenant_id_location_id_created_at_837ca80b47"
    t.index ["tenant_id", "status", "created_at"], name: "index_job_applications_on_tenant_id_and_status_and_created_at"
    t.index ["tenant_id"], name: "index_job_applications_on_tenant_id"
    t.index ["website_id"], name: "index_job_applications_on_website_id"
  end

  create_table "job_postings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.bigint "location_id"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_job_postings_on_location_id"
    t.index ["tenant_id", "key"], name: "index_job_postings_on_tenant_id_and_key", unique: true
    t.index ["tenant_id", "status", "created_at"], name: "index_job_postings_on_tenant_id_and_status_and_created_at"
    t.index ["tenant_id"], name: "index_job_postings_on_tenant_id"
  end

  create_table "lead_histories", force: :cascade do |t|
    t.bigint "actor_id"
    t.string "change_type", null: false
    t.jsonb "changeset", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "from_status"
    t.bigint "lead_id", null: false
    t.text "note"
    t.datetime "occurred_at", null: false
    t.bigint "tenant_id", null: false
    t.string "to_status"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_lead_histories_on_actor_id"
    t.index ["lead_id"], name: "index_lead_histories_on_lead_id"
    t.index ["tenant_id", "lead_id", "occurred_at"], name: "index_lead_histories_on_tenant_id_and_lead_id_and_occurred_at"
    t.index ["tenant_id"], name: "index_lead_histories_on_tenant_id"
  end

  create_table "leads", force: :cascade do |t|
    t.decimal "actual_value", precision: 12, scale: 2
    t.datetime "closed_at"
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.decimal "estimated_value", precision: 12, scale: 2
    t.datetime "follow_up_at"
    t.string "idempotency_key", null: false
    t.string "lead_type", null: false
    t.bigint "location_id"
    t.string "lost_reason"
    t.text "message"
    t.datetime "occurred_at", null: false
    t.bigint "owner_id"
    t.text "page_url", default: "unknown", null: false
    t.string "request_id", null: false
    t.string "source", default: "unknown", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "utm_campaign", default: "unknown", null: false
    t.string "utm_medium", default: "unknown", null: false
    t.string "utm_source", default: "unknown", null: false
    t.bigint "website_id", null: false
    t.index ["contact_id"], name: "index_leads_on_contact_id"
    t.index ["location_id"], name: "index_leads_on_location_id"
    t.index ["owner_id"], name: "index_leads_on_owner_id"
    t.index ["tenant_id", "follow_up_at"], name: "index_leads_on_tenant_id_and_follow_up_at"
    t.index ["tenant_id", "idempotency_key"], name: "index_leads_on_tenant_id_and_idempotency_key", unique: true
    t.index ["tenant_id", "location_id", "created_at"], name: "index_leads_on_tenant_id_and_location_id_and_created_at"
    t.index ["tenant_id", "owner_id", "created_at"], name: "index_leads_on_tenant_id_and_owner_id_and_created_at"
    t.index ["tenant_id", "status", "created_at"], name: "index_leads_on_tenant_id_and_status_and_created_at"
    t.index ["tenant_id"], name: "index_leads_on_tenant_id"
    t.index ["website_id"], name: "index_leads_on_website_id"
  end

  create_table "locations", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "alert_email"
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "key"], name: "index_locations_on_tenant_id_and_key", unique: true
    t.index ["tenant_id"], name: "index_locations_on_tenant_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "location_id"
    t.integer "role", default: 3, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["location_id"], name: "index_memberships_on_location_id"
    t.index ["tenant_id", "user_id"], name: "index_memberships_on_tenant_id_and_user_id", unique: true
    t.index ["tenant_id"], name: "index_memberships_on_tenant_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "last_attempted_at"
    t.text "last_error"
    t.bigint "lead_id", null: false
    t.bigint "location_id"
    t.string "provider_message_id"
    t.string "recipient"
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id", "kind"], name: "index_notifications_on_lead_id_and_kind", unique: true
    t.index ["lead_id"], name: "index_notifications_on_lead_id"
    t.index ["location_id"], name: "index_notifications_on_location_id"
    t.index ["tenant_id", "status", "created_at"], name: "index_notifications_on_tenant_id_and_status_and_created_at"
    t.index ["tenant_id"], name: "index_notifications_on_tenant_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "generated_at"
    t.text "generation_error"
    t.bigint "location_id"
    t.jsonb "metrics", default: {}, null: false
    t.date "period_end", null: false
    t.date "period_start", null: false
    t.integer "status", default: 0, null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.index ["location_id"], name: "index_reports_on_location_id"
    t.index ["tenant_id", "location_id", "period_start", "period_end", "version"], name: "index_reports_on_scope_period_version", unique: true, nulls_not_distinct: true
    t.index ["tenant_id"], name: "index_reports_on_tenant_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.bigint "membership_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["membership_id"], name: "index_sessions_on_membership_id"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority"
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_location_key"
    t.string "name", null: false
    t.string "notification_email"
    t.string "slug", null: false
    t.string "time_zone", default: "America/Vancouver", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_tenants_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email_address)::text)", name: "index_users_on_lower_email", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "allowed_domain", null: false
    t.datetime "created_at", null: false
    t.bigint "fallback_location_id"
    t.string "name", null: false
    t.bigint "tenant_id", null: false
    t.string "tracking_key_digest", null: false
    t.string "tracking_key_hint", null: false
    t.datetime "updated_at", null: false
    t.index ["fallback_location_id"], name: "index_websites_on_fallback_location_id"
    t.index ["tenant_id", "allowed_domain"], name: "index_websites_on_tenant_id_and_allowed_domain", unique: true
    t.index ["tenant_id"], name: "index_websites_on_tenant_id"
    t.index ["tracking_key_digest"], name: "index_websites_on_tracking_key_digest", unique: true
  end

  create_table "workspace_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "enabled", default: false, null: false
    t.string "key", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "key"], name: "index_workspace_features_on_tenant_id_and_key", unique: true
    t.index ["tenant_id"], name: "index_workspace_features_on_tenant_id"
  end

  add_foreign_key "contacts", "tenants"
  add_foreign_key "events", "locations"
  add_foreign_key "events", "tenants"
  add_foreign_key "events", "websites"
  add_foreign_key "job_applicants", "tenants"
  add_foreign_key "job_application_histories", "job_applications"
  add_foreign_key "job_application_histories", "tenants"
  add_foreign_key "job_application_histories", "users", column: "actor_id"
  add_foreign_key "job_applications", "job_applicants"
  add_foreign_key "job_applications", "job_postings"
  add_foreign_key "job_applications", "locations"
  add_foreign_key "job_applications", "tenants"
  add_foreign_key "job_applications", "websites"
  add_foreign_key "job_postings", "locations"
  add_foreign_key "job_postings", "tenants"
  add_foreign_key "lead_histories", "leads"
  add_foreign_key "lead_histories", "tenants"
  add_foreign_key "lead_histories", "users", column: "actor_id"
  add_foreign_key "leads", "contacts"
  add_foreign_key "leads", "locations"
  add_foreign_key "leads", "tenants"
  add_foreign_key "leads", "users", column: "owner_id"
  add_foreign_key "leads", "websites"
  add_foreign_key "locations", "tenants"
  add_foreign_key "memberships", "locations"
  add_foreign_key "memberships", "tenants"
  add_foreign_key "memberships", "users"
  add_foreign_key "notifications", "leads"
  add_foreign_key "notifications", "locations"
  add_foreign_key "notifications", "tenants"
  add_foreign_key "reports", "locations"
  add_foreign_key "reports", "tenants"
  add_foreign_key "sessions", "memberships"
  add_foreign_key "sessions", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "websites", "locations", column: "fallback_location_id"
  add_foreign_key "websites", "tenants"
  add_foreign_key "workspace_features", "tenants"
end
