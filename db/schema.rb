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

ActiveRecord::Schema[7.1].define(version: 2024_05_14_162754) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "card_terminals", force: :cascade do |t|
    t.string "displayname", default: ""
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "properties"
    t.string "name", default: ""
    t.string "ct_id", default: ""
    t.macaddr "mac"
    t.inet "ip"
    t.integer "slots", default: 0
    t.boolean "connected", default: false
    t.integer "condition", default: -1
    t.bigint "connector_id"
    t.string "room", default: ""
    t.string "contact", default: ""
    t.string "plugged_in", default: ""
    t.index ["connector_id"], name: "index_card_terminals_on_connector_id"
    t.index ["location_id"], name: "index_card_terminals_on_location_id"
    t.index ["mac"], name: "index_card_terminals_on_mac", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "card_handle", default: ""
    t.string "card_type", default: ""
    t.string "iccsn", default: ""
    t.integer "slotid", default: -1
    t.datetime "insert_time", precision: nil
    t.string "card_holder_name", default: ""
    t.date "expiration_date"
    t.bigint "card_terminal_id"
    t.jsonb "properties"
    t.bigint "operational_state_id"
    t.bigint "location_id"
    t.string "lanr", default: ""
    t.string "bsnr", default: ""
    t.string "fachrichtung", default: ""
    t.string "telematikid", default: ""
    t.text "certificate"
    t.string "cert_subject_title", default: ""
    t.string "cert_subject_sn", default: ""
    t.string "cert_subject_givenname", default: ""
    t.string "cert_subject_street", default: ""
    t.string "cert_subject_postalcode", default: ""
    t.string "cert_subject_l", default: ""
    t.string "cert_subject_cn", default: ""
    t.string "cert_subject_o", default: ""
    t.bigint "context_id"
    t.index ["card_terminal_id"], name: "index_cards_on_card_terminal_id"
    t.index ["context_id"], name: "index_cards_on_context_id"
    t.index ["iccsn"], name: "index_cards_on_iccsn", unique: true
    t.index ["location_id"], name: "index_cards_on_location_id"
    t.index ["operational_state_id"], name: "index_cards_on_operational_state_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients_connectors", id: false, force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "connector_id", null: false
    t.index ["client_id", "connector_id"], name: "index_clients_connectors_on_client_id_and_connector_id", unique: true
    t.index ["connector_id", "client_id"], name: "index_clients_connectors_on_connector_id_and_client_id", unique: true
  end

  create_table "connector_contexts", force: :cascade do |t|
    t.bigint "connector_id", null: false
    t.bigint "context_id", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connector_id", "context_id"], name: "index_connector_contexts_on_connector_id_and_context_id", unique: true
    t.index ["connector_id"], name: "index_connector_contexts_on_connector_id"
    t.index ["context_id", "connector_id"], name: "index_connector_contexts_on_context_id_and_connector_id", unique: true
    t.index ["context_id"], name: "index_connector_contexts_on_context_id"
    t.index ["position"], name: "index_connector_contexts_on_position"
  end

  create_table "connectors", force: :cascade do |t|
    t.string "name", default: ""
    t.inet "ip", null: false
    t.string "sds_url", default: ""
    t.boolean "manual_update", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "sds_xml"
    t.jsonb "connector_services"
    t.datetime "last_check", precision: nil
    t.datetime "last_check_ok", precision: nil
    t.integer "condition", default: -1
    t.boolean "soap_request_success", default: false
    t.boolean "vpnti_online", default: false
    t.datetime "sds_updated_at", precision: nil
    t.index ["condition"], name: "index_connectors_on_condition"
  end

  create_table "connectors_locations", id: false, force: :cascade do |t|
    t.bigint "connector_id", null: false
    t.bigint "location_id", null: false
    t.index ["connector_id", "location_id"], name: "index_connectors_locations_on_connector_id_and_location_id", unique: true
    t.index ["location_id", "connector_id"], name: "index_connectors_locations_on_location_id_and_connector_id", unique: true
  end

  create_table "contexts", force: :cascade do |t|
    t.string "mandant", null: false
    t.string "client_system", null: false
    t.string "workplace", null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "locations", force: :cascade do |t|
    t.string "lid", null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "operational_states", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wobauth_authorities", force: :cascade do |t|
    t.bigint "authorizable_id"
    t.string "authorizable_type"
    t.bigint "role_id"
    t.bigint "authorized_for_id"
    t.string "authorized_for_type"
    t.date "valid_from"
    t.date "valid_until"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authorizable_id"], name: "index_wobauth_authorities_on_authorizable_id"
    t.index ["authorized_for_id"], name: "index_wobauth_authorities_on_authorized_for_id"
    t.index ["role_id"], name: "index_wobauth_authorities_on_role_id"
  end

  create_table "wobauth_groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "wobauth_memberships", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.boolean "auto", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_wobauth_memberships_on_group_id"
    t.index ["user_id"], name: "index_wobauth_memberships_on_user_id"
  end

  create_table "wobauth_roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "wobauth_users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.text "gruppen"
    t.string "sn"
    t.string "givenname"
    t.string "displayname"
    t.string "telephone"
    t.string "active_directory_guid"
    t.string "userprincipalname"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title", default: ""
    t.string "position", default: ""
    t.string "department", default: ""
    t.string "company", default: ""
    t.index ["reset_password_token"], name: "index_wobauth_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_wobauth_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "card_terminals", "connectors"
  add_foreign_key "card_terminals", "locations"
  add_foreign_key "connector_contexts", "connectors"
  add_foreign_key "connector_contexts", "contexts"
end
