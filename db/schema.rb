# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151218000000) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.text     "body",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace",     limit: 255
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "posts", force: :cascade do |t|
    t.text     "content",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",            limit: 4
    t.boolean  "public",                              default: false, null: false
    t.datetime "burn_after_date"
    t.string   "random_token",       limit: 255
    t.text     "structured_content", limit: 16777215
    t.string   "privly_application", limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                           limit: 255, default: "",    null: false
    t.string   "encrypted_password",              limit: 255, default: ""
    t.string   "reset_password_token",            limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",              limit: 255
    t.string   "last_sign_in_ip",                 limit: 255
    t.string   "confirmation_token",              limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                 limit: 4,   default: 0
    t.string   "unlock_token",                    limit: 255
    t.datetime "locked_at"
    t.string   "authentication_token",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token",                limit: 80
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",                limit: 4
    t.integer  "invited_by_id",                   limit: 4
    t.string   "invited_by_type",                 limit: 255
    t.boolean  "pending_invitation",                          default: false, null: false
    t.datetime "last_emailed"
    t.integer  "alpha_invites",                   limit: 4,   default: 0,     null: false
    t.integer  "beta_invites",                    limit: 4,   default: 0,     null: false
    t.float    "forever_account_value",           limit: 24,  default: 0.0,   null: false
    t.float    "permissioned_requests_served",    limit: 24,  default: 0.0,   null: false
    t.float    "nonpermissioned_requests_served", limit: 24,  default: 0.0,   null: false
    t.boolean  "can_post",                                    default: false, null: false
    t.boolean  "notifications",                               default: true,  null: false
    t.string   "domain",                          limit: 255, default: "",    null: false
    t.boolean  "wants_to_test",                               default: false, null: false
    t.string   "platform",                        limit: 255
    t.datetime "invitation_created_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["domain"], name: "index_users_on_domain", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
