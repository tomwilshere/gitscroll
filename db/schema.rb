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

ActiveRecord::Schema.define(version: 20140617161454) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "commit_files", force: true do |t|
    t.string   "commit_id"
    t.string   "git_hash"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "commit_files", ["commit_id"], name: "index_commit_files_on_commit_id", using: :btree
  add_index "commit_files", ["git_hash", "project_id"], name: "index_commit_files_on_git_hash_and_project_id", unique: true, using: :btree
  add_index "commit_files", ["git_hash"], name: "index_commit_files_on_git_hash", using: :btree
  add_index "commit_files", ["project_id"], name: "index_commit_files_on_project_id", using: :btree

  create_table "commits", force: true do |t|
    t.integer  "project_id"
    t.string   "git_hash"
    t.text     "message"
    t.integer  "author_id"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "deleted_files"
    t.integer  "commit_number"
  end

  add_index "commits", ["author_id"], name: "index_commits_on_author_id", using: :btree
  add_index "commits", ["git_hash", "project_id"], name: "index_commits_on_git_hash_and_project_id", unique: true, using: :btree
  add_index "commits", ["git_hash"], name: "index_commits_on_git_hash", using: :btree
  add_index "commits", ["project_id"], name: "index_commits_on_project_id", using: :btree

  create_table "false_positives", force: true do |t|
    t.string   "path"
    t.integer  "project_id"
    t.text     "comment"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "false_positives", ["project_id"], name: "index_false_positives_on_project_id", using: :btree

  create_table "file_metrics", force: true do |t|
    t.string   "commit_file_id"
    t.integer  "metric_id"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "file_metrics", ["commit_file_id"], name: "index_file_metrics_on_commit_file_id", using: :btree
  add_index "file_metrics", ["metric_id"], name: "index_file_metrics_on_metric_id", using: :btree
  add_index "file_metrics", ["project_id"], name: "index_file_metrics_on_project_id", using: :btree

  create_table "fix_files", force: true do |t|
    t.integer  "project_id"
    t.string   "commit_id"
    t.string   "commit_file_id"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "score"
  end

  add_index "fix_files", ["project_id"], name: "index_fix_files_on_project_id", using: :btree

  create_table "metric_stats", force: true do |t|
    t.integer  "project_id"
    t.integer  "metric_id"
    t.float    "min"
    t.float    "max"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metric_stats", ["metric_id"], name: "index_metric_stats_on_metric_id", using: :btree
  add_index "metric_stats", ["project_id"], name: "index_metric_stats_on_project_id", using: :btree

  create_table "metrics", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "extension_list"
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "repo_remote_url"
    t.string   "repo_local_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_commits"
  end

end
