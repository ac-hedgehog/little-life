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

ActiveRecord::Schema.define(:version => 20121105104840) do

  create_table "colonies", :force => true do |t|
    t.string   "name",       :default => "Creature"
    t.integer  "rows",       :default => 5
    t.integer  "cols",       :default => 5
    t.text     "text_cells"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "evolutions", :force => true do |t|
    t.string   "field_name",         :default => "Evolution Field"
    t.integer  "field_rows"
    t.integer  "field_cols"
    t.string   "main_name",          :default => "Creature"
    t.integer  "main_top",           :default => 0
    t.integer  "main_left",          :default => 0
    t.integer  "life_cycles_number"
    t.integer  "population_size"
    t.integer  "evolution_steps"
    t.integer  "mutation_level"
    t.integer  "task_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  create_table "fields", :force => true do |t|
    t.string   "name",       :default => "Field"
    t.integer  "rows",       :default => 10
    t.integer  "cols",       :default => 10
    t.text     "text_cells"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "tasks", :force => true do |t|
    t.string   "goal"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "templates", :force => true do |t|
    t.string   "name",       :default => "Template"
    t.integer  "rows",       :default => 5
    t.integer  "cols",       :default => 5
    t.text     "text_cells"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

end
