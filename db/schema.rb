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

ActiveRecord::Schema[8.1].define(version: 2026_01_03_102541) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "card_contexts", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.bigint "context_id", null: false
    t.datetime "created_at", null: false
    t.integer "left_tries"
    t.string "pin_status", default: ""
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["card_id", "context_id"], name: "index_card_contexts_on_card_id_and_context_id", unique: true
    t.index ["card_id"], name: "index_card_contexts_on_card_id"
    t.index ["context_id", "card_id"], name: "index_card_contexts_on_context_id_and_card_id", unique: true
    t.index ["context_id"], name: "index_card_contexts_on_context_id"
    t.index ["pin_status"], name: "index_card_contexts_on_pin_status"
    t.index ["position"], name: "index_card_contexts_on_position"
  end

  create_table "card_terminal_slots", force: :cascade do |t|
    t.bigint "card_terminal_id", null: false
    t.datetime "created_at", null: false
    t.integer "slotid", default: -1
    t.datetime "updated_at", null: false
    t.index ["card_terminal_id", "slotid"], name: "index_card_terminal_slots_on_card_terminal_id_and_slotid", unique: true
    t.index ["card_terminal_id"], name: "index_card_terminal_slots_on_card_terminal_id"
  end

  create_table "card_terminals", force: :cascade do |t|
    t.bigint "acknowledge_id"
    t.string "admin_pin"
    t.integer "condition", default: -1
    t.string "condition_message", default: ""
    t.boolean "connected", default: false
    t.bigint "connector_id"
    t.string "contact", default: ""
    t.datetime "created_at", null: false
    t.string "ct_id", default: ""
    t.inet "current_ip"
    t.datetime "deleted_at", precision: nil
    t.date "delivery_date"
    t.string "displayname", default: ""
    t.string "firmware_version", default: ""
    t.string "id_product", default: ""
    t.string "identification", default: ""
    t.string "idle_message", default: ""
    t.inet "ip"
    t.datetime "last_check", precision: nil
    t.datetime "last_ok", precision: nil
    t.bigint "location_id"
    t.macaddr "mac"
    t.string "name", default: ""
    t.bigint "network_id"
    t.integer "pin_mode", default: 0
    t.string "plugged_in", default: ""
    t.jsonb "properties"
    t.datetime "rebooted_at", precision: nil
    t.string "room", default: ""
    t.string "serial", default: ""
    t.integer "slot1_plug_cycles", default: 0
    t.integer "slot2_plug_cycles", default: 0
    t.integer "slot3_plug_cycles", default: 0
    t.integer "slot4_plug_cycles", default: 0
    t.integer "slots", default: 0
    t.string "supplier", default: ""
    t.datetime "updated_at", null: false
    t.integer "uptime_reboot", default: 0
    t.integer "uptime_total", default: 0
    t.index ["condition"], name: "index_card_terminals_on_condition"
    t.index ["connector_id"], name: "index_card_terminals_on_connector_id"
    t.index ["location_id"], name: "index_card_terminals_on_location_id"
    t.index ["mac"], name: "index_card_terminals_on_mac", unique: true
    t.index ["network_id"], name: "index_card_terminals_on_network_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "acknowledge_id"
    t.string "bsnr", default: ""
    t.string "card_handle", default: ""
    t.string "card_holder_name", default: ""
    t.bigint "card_terminal_slot_id"
    t.string "card_type", default: ""
    t.string "cert_subject_cn", default: ""
    t.string "cert_subject_givenname", default: ""
    t.string "cert_subject_l", default: ""
    t.string "cert_subject_o", default: ""
    t.string "cert_subject_postalcode", default: ""
    t.string "cert_subject_sn", default: ""
    t.string "cert_subject_street", default: ""
    t.string "cert_subject_title", default: ""
    t.text "certificate"
    t.integer "condition", default: -1
    t.string "condition_message", default: ""
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.date "expiration_date"
    t.string "fachrichtung", default: ""
    t.string "iccsn", default: ""
    t.datetime "insert_time", precision: nil
    t.string "lanr", default: ""
    t.datetime "last_check", precision: nil
    t.datetime "last_ok", precision: nil
    t.bigint "location_id"
    t.string "name", default: ""
    t.string "object_system_version", default: ""
    t.bigint "operational_state_id"
    t.jsonb "properties"
    t.string "telematikid", default: ""
    t.datetime "updated_at", null: false
    t.index ["card_terminal_slot_id"], name: "index_cards_on_card_terminal_slot_id", unique: true
    t.index ["condition"], name: "index_cards_on_condition"
    t.index ["iccsn"], name: "index_cards_on_iccsn", unique: true
    t.index ["location_id"], name: "index_cards_on_location_id"
    t.index ["object_system_version"], name: "index_cards_on_object_system_version"
    t.index ["operational_state_id"], name: "index_cards_on_operational_state_id"
  end

  create_table "client_certificates", force: :cascade do |t|
    t.text "cert"
    t.string "client_system", default: ""
    t.datetime "created_at", null: false
    t.date "expiration_date"
    t.string "name", default: ""
    t.string "passphrase", default: ""
    t.text "pkey"
    t.datetime "updated_at", null: false
  end

  create_table "client_certificates_connectors", id: false, force: :cascade do |t|
    t.bigint "client_certificate_id", null: false
    t.bigint "connector_id", null: false
    t.index ["client_certificate_id", "connector_id"], name: "idx_on_client_certificate_id_connector_id_892ac5cf15", unique: true
    t.index ["connector_id", "client_certificate_id"], name: "idx_on_connector_id_client_certificate_id_7f6bd688da", unique: true
  end

  create_table "connector_contexts", force: :cascade do |t|
    t.bigint "connector_id", null: false
    t.bigint "context_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["connector_id", "context_id"], name: "index_connector_contexts_on_connector_id_and_context_id", unique: true
    t.index ["connector_id"], name: "index_connector_contexts_on_connector_id"
    t.index ["context_id", "connector_id"], name: "index_connector_contexts_on_context_id_and_connector_id", unique: true
    t.index ["context_id"], name: "index_connector_contexts_on_context_id"
    t.index ["position"], name: "index_connector_contexts_on_position"
  end

  create_table "connectors", force: :cascade do |t|
    t.bigint "acknowledge_id"
    t.string "admin_url", default: ""
    t.string "auth_password", default: ""
    t.string "auth_user", default: ""
    t.integer "authentication", default: 0
    t.integer "boot_mode", default: 0
    t.integer "condition", default: -1
    t.string "condition_message", default: ""
    t.jsonb "connector_services"
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.date "expiration_date"
    t.string "firmware_version", default: ""
    t.string "iccsn", default: ""
    t.string "id_contract", default: ""
    t.inet "ip", null: false
    t.datetime "last_check", precision: nil
    t.datetime "last_ok", precision: nil
    t.boolean "manual_update", default: false
    t.string "name", default: ""
    t.datetime "rebooted_at", precision: nil
    t.datetime "sds_updated_at", precision: nil
    t.string "sds_url", default: ""
    t.text "sds_xml"
    t.string "serial", default: ""
    t.string "short_name", default: ""
    t.boolean "soap_request_success", default: false
    t.datetime "updated_at", null: false
    t.boolean "use_tls", default: false
    t.boolean "vpnti_online", default: false
    t.index ["boot_mode"], name: "index_connectors_on_boot_mode"
    t.index ["condition"], name: "index_connectors_on_condition"
  end

  create_table "connectors_locations", id: false, force: :cascade do |t|
    t.bigint "connector_id", null: false
    t.bigint "location_id", null: false
    t.index ["connector_id", "location_id"], name: "index_connectors_locations_on_connector_id_and_location_id", unique: true
    t.index ["location_id", "connector_id"], name: "index_connectors_locations_on_location_id_and_connector_id", unique: true
  end

  create_table "contexts", force: :cascade do |t|
    t.string "client_system", null: false
    t.datetime "created_at", null: false
    t.string "description", default: ""
    t.string "mandant", null: false
    t.datetime "updated_at", null: false
    t.string "workplace", null: false
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "kt_proxies", force: :cascade do |t|
    t.bigint "card_terminal_id"
    t.inet "card_terminal_ip"
    t.integer "card_terminal_port", default: 4742
    t.datetime "created_at", null: false
    t.inet "incoming_ip"
    t.integer "incoming_port"
    t.string "name", default: ""
    t.inet "outgoing_ip"
    t.integer "outgoing_port"
    t.bigint "ti_client_id", null: false
    t.datetime "updated_at", null: false
    t.string "uuid", null: false
    t.inet "wireguard_ip"
    t.index ["card_terminal_id"], name: "index_kt_proxies_on_card_terminal_id"
    t.index ["incoming_ip", "incoming_port"], name: "in_socket", unique: true
    t.index ["outgoing_ip", "outgoing_port"], name: "out_socket", unique: true
    t.index ["ti_client_id"], name: "index_kt_proxies_on_ti_client_id"
    t.index ["uuid"], name: "index_kt_proxies_on_uuid", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: ""
    t.string "lid", null: false
    t.datetime "updated_at", null: false
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "acknowledge_id"
    t.string "action", default: ""
    t.integer "condition", default: -1
    t.datetime "created_at", null: false
    t.boolean "is_valid", default: false
    t.datetime "last_seen", precision: nil
    t.string "level", default: ""
    t.bigint "loggable_id", null: false
    t.string "loggable_type", null: false
    t.text "message"
    t.datetime "since", precision: nil
    t.datetime "updated_at", null: false
    t.index ["is_valid"], name: "index_logs_on_is_valid"
    t.index ["level"], name: "index_logs_on_level"
    t.index ["loggable_type", "loggable_id"], name: "index_logs_on_loggable"
  end

  create_table "networks", force: :cascade do |t|
    t.integer "accessibility", default: 0
    t.datetime "created_at", null: false
    t.bigint "location_id", null: false
    t.cidr "netzwerk"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_networks_on_location_id"
  end

  create_table "notes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "mail_to"
    t.bigint "notable_id", null: false
    t.string "notable_type", null: false
    t.string "subject"
    t.integer "type", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "valid_until"
    t.boolean "with_mail", default: false
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "operational_states", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description", default: ""
    t.string "name", default: "", null: false
    t.boolean "operational", default: false
    t.datetime "updated_at", null: false
    t.index ["operational"], name: "index_operational_states_on_operational"
  end

  create_table "situation_picture", force: :cascade do |t|
    t.integer "availability", default: 0
    t.string "bu", default: ""
    t.string "ci", default: ""
    t.string "comment", default: ""
    t.datetime "created_at", null: false
    t.boolean "muted", default: false
    t.string "name", default: ""
    t.string "organization", default: ""
    t.string "pdt", default: ""
    t.string "product", default: ""
    t.string "tid", default: ""
    t.datetime "time", precision: nil
    t.datetime "updated_at", null: false
    t.index ["availability"], name: "index_situation_picture_on_availability"
    t.index ["bu"], name: "index_situation_picture_on_bu"
    t.index ["pdt"], name: "index_situation_picture_on_pdt"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.bigint "taggable_id", null: false
    t.string "taggable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "terminal_workplaces", force: :cascade do |t|
    t.bigint "card_terminal_id", null: false
    t.string "client_system", default: ""
    t.datetime "created_at", null: false
    t.string "mandant", default: ""
    t.datetime "updated_at", null: false
    t.bigint "workplace_id", null: false
    t.index ["card_terminal_id", "mandant", "client_system", "workplace_id"], name: "idx_on_card_terminal_id_mandant_client_system_workp_6aee375d98", unique: true
    t.index ["card_terminal_id", "workplace_id"], name: "index_terminal_workplaces_on_card_terminal_id_and_workplace_id"
    t.index ["card_terminal_id"], name: "index_terminal_workplaces_on_card_terminal_id"
    t.index ["client_system"], name: "index_terminal_workplaces_on_client_system"
    t.index ["mandant"], name: "index_terminal_workplaces_on_mandant"
    t.index ["workplace_id", "card_terminal_id"], name: "index_terminal_workplaces_on_workplace_id_and_card_terminal_id"
    t.index ["workplace_id"], name: "index_terminal_workplaces_on_workplace_id"
  end

  create_table "ti_clients", force: :cascade do |t|
    t.string "client_secret"
    t.bigint "connector_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["connector_id"], name: "index_ti_clients_on_connector_id", unique: true
  end

  create_table "wobauth_authorities", force: :cascade do |t|
    t.bigint "authorizable_id"
    t.string "authorizable_type"
    t.bigint "authorized_for_id"
    t.string "authorized_for_type"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "role_id"
    t.datetime "updated_at", precision: nil, null: false
    t.date "valid_from"
    t.date "valid_until"
    t.index ["authorizable_id"], name: "index_wobauth_authorities_on_authorizable_id"
    t.index ["authorized_for_id"], name: "index_wobauth_authorities_on_authorized_for_id"
    t.index ["role_id"], name: "index_wobauth_authorities_on_role_id"
  end

  create_table "wobauth_groups", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "wobauth_memberships", force: :cascade do |t|
    t.boolean "auto", default: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "group_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["group_id"], name: "index_wobauth_memberships_on_group_id"
    t.index ["user_id"], name: "index_wobauth_memberships_on_user_id"
  end

  create_table "wobauth_roles", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "wobauth_users", force: :cascade do |t|
    t.string "active_directory_guid"
    t.string "company", default: ""
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "department", default: ""
    t.string "displayname"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "givenname"
    t.text "gruppen"
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "position", default: ""
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "sn"
    t.string "telephone"
    t.string "title", default: ""
    t.datetime "updated_at", precision: nil, null: false
    t.string "username", default: "", null: false
    t.string "userprincipalname"
    t.index ["reset_password_token"], name: "index_wobauth_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_wobauth_users_on_username", unique: true
  end

  create_table "workplaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_seen", precision: nil
    t.string "name", default: ""
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "card_contexts", "cards"
  add_foreign_key "card_contexts", "contexts"
  add_foreign_key "card_terminal_slots", "card_terminals"
  add_foreign_key "card_terminals", "connectors"
  add_foreign_key "card_terminals", "locations"
  add_foreign_key "connector_contexts", "connectors"
  add_foreign_key "connector_contexts", "contexts"
  add_foreign_key "kt_proxies", "ti_clients"
  add_foreign_key "networks", "locations"
  add_foreign_key "notes", "wobauth_users", column: "user_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "terminal_workplaces", "card_terminals"
  add_foreign_key "terminal_workplaces", "workplaces"
  add_foreign_key "ti_clients", "connectors"
end
