# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_240_403_213_156) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'games', force: :cascade do |t|
    t.integer 'player_one'
    t.integer 'player_two'
    t.integer 'winner'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'pieces', force: :cascade do |t|
    t.integer 'game_id'
    t.integer 'player_id'
    t.string 'name', default: 'Sir Robin'
    t.string 'piece_type', default: 'pawn', null: false
    t.integer 'position_x'
    t.integer 'position_y'
    t.boolean 'checked'
    t.boolean 'active'
    t.boolean 'moved'
    t.boolean 'en_passant'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'color'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'display_name', null: false
    t.string 'role', default: 'player', null: false
    t.integer 'rank', default: 900
    t.integer 'level', default: 1
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'guest', default: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'games', 'users', column: 'player_one'
  add_foreign_key 'games', 'users', column: 'player_two'
  add_foreign_key 'games', 'users', column: 'winner'
end
