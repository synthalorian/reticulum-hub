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

ActiveRecord::Schema[8.1].define(version: 2026_05_31_023354) do
  create_table "alert_rules", force: :cascade do |t|
    t.string "condition"
    t.datetime "created_at", null: false
    t.boolean "enabled"
    t.json "metadata"
    t.string "name"
    t.json "notification_channels"
    t.float "threshold"
    t.datetime "updated_at", null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.datetime "acknowledged_at"
    t.integer "alert_rule_id", null: false
    t.datetime "created_at", null: false
    t.json "details"
    t.string "message"
    t.datetime "resolved_at"
    t.string "severity"
    t.string "status"
    t.datetime "triggered_at"
    t.datetime "updated_at", null: false
    t.index ["alert_rule_id"], name: "index_alerts_on_alert_rule_id"
  end

  create_table "interfaces", force: :cascade do |t|
    t.integer "bandwidth_in"
    t.integer "bandwidth_out"
    t.json "config"
    t.datetime "created_at", null: false
    t.float "error_rate"
    t.string "interface_type"
    t.datetime "last_seen"
    t.json "metadata"
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "uptime"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.boolean "delivered"
    t.string "direction"
    t.json "metadata"
    t.boolean "read"
    t.string "recipient_hash"
    t.string "sender_hash"
    t.datetime "sent_at"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination_hash"
    t.integer "hops"
    t.datetime "last_seen"
    t.json "metadata"
    t.string "name"
    t.json "services"
    t.datetime "updated_at", null: false
  end

  create_table "peers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination_hash"
    t.integer "hops"
    t.datetime "last_seen"
    t.float "link_quality"
    t.json "metadata"
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.json "metadata"
    t.string "name"
    t.integer "node_id", null: false
    t.integer "port"
    t.string "service_type"
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_services_on_node_id"
  end

  create_table "system_stats", force: :cascade do |t|
    t.integer "bandwidth_in"
    t.integer "bandwidth_out"
    t.float "cpu_percent"
    t.datetime "created_at", null: false
    t.integer "interface_count"
    t.float "memory_percent"
    t.json "metadata"
    t.integer "peer_count"
    t.datetime "updated_at", null: false
    t.integer "uptime"
  end

  add_foreign_key "alerts", "alert_rules"
  add_foreign_key "services", "nodes"
end
