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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120906045507) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "identity_providers", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.text     "content",            :limit => 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "public",                            :default => false, :null => false
    t.datetime "burn_after_date"
    t.string   "random_token"
    t.text     "structured_content"
  end

  create_table "shares", :force => true do |t|
    t.integer  "post_id"
    t.integer  "identity_provider_id"
    t.string   "identity"
    t.string   "identity_pair"
    t.boolean  "can_show"
    t.boolean  "can_destroy"
    t.boolean  "can_update"
    t.boolean  "can_share"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shares", ["identity_pair"], :name => "index_shares_on_identity_pair"

  create_table "users", :force => true do |t|
    t.string   "email",                                         :default => "",    :null => false
    t.string   "encrypted_password",                            :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                               :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                         :default => false, :null => false
    t.string   "invitation_token",                :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.boolean  "pending_invitation",                            :default => false, :null => false
    t.datetime "last_emailed"
    t.integer  "alpha_invites",                                 :default => 0,     :null => false
    t.integer  "beta_invites",                                  :default => 0,     :null => false
    t.float    "forever_account_value",                         :default => 0.0,   :null => false
    t.float    "permissioned_requests_served",                  :default => 0.0,   :null => false
    t.float    "nonpermissioned_requests_served",               :default => 0.0,   :null => false
    t.boolean  "can_post",                                      :default => false, :null => false
    t.boolean  "wants_to_test",                                 :default => false, :null => false
    t.boolean  "accepted_test_statement",                       :default => false, :null => false
    t.boolean  "notifications",                                 :default => true,  :null => false
    t.string   "domain",                                        :default => "",    :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["domain"], :name => "index_users_on_domain"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "zero_bins", :force => true do |t|
    t.string   "iv"
    t.string   "salt"
    t.text     "ct"
    t.string   "random_token"
    t.datetime "burn_after_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
