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

ActiveRecord::Schema.define(version: 20190907081528) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "combi_planner_shopping_list_portions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "planner_shopping_list_id"
    t.bigint "ingredient_id"
    t.bigint "unit_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_combi_planner_shopping_list_portions_on_ingredient_id"
    t.index ["planner_shopping_list_id"], name: "index_combi_planner_shopping_list_portions"
    t.index ["unit_id"], name: "index_combi_planner_shopping_list_portions_on_unit_id"
    t.index ["user_id"], name: "index_combi_planner_shopping_list_portions_on_user_id"
  end

  create_table "cupboard_users", force: :cascade do |t|
    t.bigint "cupboard_id"
    t.bigint "user_id"
    t.boolean "owner", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "accepted", default: false, null: false
    t.index ["cupboard_id"], name: "index_cupboard_users_on_cupboard_id"
    t.index ["user_id"], name: "index_cupboard_users_on_user_id"
  end

  create_table "cupboards", force: :cascade do |t|
    t.bigint "user_id"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.boolean "setup", default: false
    t.boolean "communal", default: false, null: false
    t.index ["user_id"], name: "index_cupboards_on_user_id"
  end

  create_table "favourite_recipes", force: :cascade do |t|
    t.bigint "recipe_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_favourite_recipes_on_recipe_id"
    t.index ["user_id"], name: "index_favourite_recipes_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.boolean "vegan", default: false
    t.boolean "vegetarian", default: false
    t.boolean "gluten_free", default: false
    t.boolean "dairy_free", default: false
    t.boolean "kosher", default: false
    t.boolean "common", default: false
    t.boolean "searchable", default: true
    t.bigint "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unit_id"], name: "index_ingredients_on_unit_id"
  end

  create_table "planner_recipes", force: :cascade do |t|
    t.bigint "recipe_id"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["recipe_id"], name: "index_planner_recipes_on_recipe_id"
    t.index ["user_id"], name: "index_planner_recipes_on_user_id"
  end

  create_table "planner_shopping_list_portions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "planner_shopping_list_id"
    t.bigint "planner_recipe_id"
    t.bigint "ingredient_id"
    t.bigint "unit_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "combi_planner_shopping_list_portion_id"
    t.index ["combi_planner_shopping_list_portion_id"], name: "index_planner_shopping_list_portion_to_combi"
    t.index ["ingredient_id"], name: "index_planner_shopping_list_portions_on_ingredient_id"
    t.index ["planner_recipe_id"], name: "index_planner_shopping_list_portions_on_planner_recipe_id"
    t.index ["planner_shopping_list_id"], name: "index_planner_shopping_list__portions"
    t.index ["unit_id"], name: "index_planner_shopping_list_portions_on_unit_id"
    t.index ["user_id"], name: "index_planner_shopping_list_portions_on_user_id"
  end

  create_table "planner_shopping_lists", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ready", default: true, null: false
    t.index ["user_id"], name: "index_planner_shopping_lists_on_user_id"
  end

  create_table "portions", force: :cascade do |t|
    t.bigint "recipe_id"
    t.bigint "ingredient_id"
    t.integer "unit_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_portions_on_ingredient_id"
    t.index ["recipe_id"], name: "index_portions_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.boolean "live", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cuisine"
    t.string "prep_time"
    t.string "cook_time"
    t.string "yield"
    t.string "note"
    t.integer "user_id"
    t.boolean "public", default: true, null: false
    t.boolean "show_users_name", default: true, null: false
  end

  create_table "shopping_list_portions", force: :cascade do |t|
    t.bigint "ingredient_id"
    t.bigint "shopping_list_id"
    t.integer "unit_id"
    t.integer "recipe_number"
    t.decimal "portion_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "stock_amount"
    t.boolean "in_cupboard", default: false
    t.decimal "percent_in_cupboard"
    t.boolean "enough_in_cupboard", default: false
    t.boolean "plenty_in_cupboard", default: false
    t.boolean "checked", default: false
    t.string "unit_name"
    t.index ["ingredient_id"], name: "index_shopping_list_portions_on_ingredient_id"
    t.index ["shopping_list_id"], name: "index_shopping_list_portions_on_shopping_list_id"
  end

  create_table "shopping_list_recipes", force: :cascade do |t|
    t.bigint "recipe_id"
    t.bigint "shopping_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_shopping_list_recipes_on_recipe_id"
    t.index ["shopping_list_id"], name: "index_shopping_list_recipes_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "archived", default: false
    t.index ["user_id"], name: "index_shopping_lists_on_user_id"
  end

  create_table "stock_users", force: :cascade do |t|
    t.bigint "stock_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_stock_users_on_stock_id"
    t.index ["user_id"], name: "index_stock_users_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "cupboard_id"
    t.bigint "ingredient_id"
    t.date "use_by_date"
    t.integer "unit_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hidden", default: false
    t.boolean "always_available", default: false, null: false
    t.bigint "planner_recipe_id"
    t.index ["cupboard_id"], name: "index_stocks_on_cupboard_id"
    t.index ["ingredient_id"], name: "index_stocks_on_ingredient_id"
    t.index ["planner_recipe_id"], name: "index_stocks_on_planner_recipe_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "unit_type"
    t.decimal "metric_ratio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_fav_stocks", force: :cascade do |t|
    t.integer "ingredient_id"
    t.integer "stock_amount"
    t.integer "unit_id"
    t.integer "user_id"
    t.integer "standard_use_by_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_recipe_stock_matches", force: :cascade do |t|
    t.integer "user_id"
    t.integer "recipe_id"
    t.decimal "ingredient_stock_match_decimal"
    t.integer "num_ingredients_total"
    t.integer "num_stock_ingredients"
    t.integer "num_needed_ingredients"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "waste_saving_rating", default: "0.0"
  end

  create_table "user_settings", force: :cascade do |t|
    t.integer "user_id"
    t.boolean "notify", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notify_day", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.boolean "demo", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "combi_planner_shopping_list_portions", "ingredients"
  add_foreign_key "combi_planner_shopping_list_portions", "planner_shopping_lists"
  add_foreign_key "combi_planner_shopping_list_portions", "units"
  add_foreign_key "combi_planner_shopping_list_portions", "users"
  add_foreign_key "planner_recipes", "recipes"
  add_foreign_key "planner_recipes", "users"
  add_foreign_key "planner_shopping_list_portions", "combi_planner_shopping_list_portions"
  add_foreign_key "planner_shopping_list_portions", "ingredients"
  add_foreign_key "planner_shopping_list_portions", "planner_recipes"
  add_foreign_key "planner_shopping_list_portions", "planner_shopping_lists"
  add_foreign_key "planner_shopping_list_portions", "units"
  add_foreign_key "planner_shopping_list_portions", "users"
  add_foreign_key "planner_shopping_lists", "users"
  add_foreign_key "shopping_lists", "users"
  add_foreign_key "stocks", "planner_recipes"
end
