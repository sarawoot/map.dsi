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

ActiveRecord::Schema.define(version: 20150324050404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "cca00_02", id: false, force: :cascade do |t|
    t.string  "sitecode"
    t.string  "ptcode"
    t.string  "title"
    t.string  "name"
    t.string  "surname"
    t.string  "v2"
    t.string  "bdatedb"
    t.string  "age"
    t.string  "v3"
    t.string  "add1n1"
    t.string  "add1n2"
    t.string  "add1n3"
    t.string  "add1n4"
    t.string  "add1n5"
    t.string  "dolacode"
    t.string  "add1n6"
    t.string  "add1n7code"
    t.string  "add1n7"
    t.string  "add1n8code"
    t.string  "add1n8"
    t.string  "add1n9"
    t.boolean "us"
    t.boolean "uscca"
    t.integer "cases_register"
    t.integer "cases_ultrasound"
    t.integer "cases_refer"
  end

  add_index "cca00_02", ["sitecode", "ptcode"], name: "sitept_ndx", using: :btree

  create_table "cca_count", id: false, force: :cascade do |t|
    t.string  "dolacode"
    t.integer "cases",    limit: 8
  end

  create_table "cca_refer", id: false, force: :cascade do |t|
    t.string  "dolacode"
    t.integer "cases",    limit: 8
  end

  create_table "cca_us", id: false, force: :cascade do |t|
    t.string  "dolacode"
    t.integer "cases",    limit: 8
  end

  create_table "comment_complaints", force: :cascade do |t|
    t.text     "description"
    t.integer  "complaint_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text     "description"
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "approved",    limit: 1
    t.integer  "approved_by"
  end

  create_table "complaints", force: :cascade do |t|
    t.text     "description"
    t.integer  "user_id"
    t.string   "status",      limit: 255, default: "wait"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "title",       limit: 255
    t.string   "file",        limit: 255
  end

# Could not dump table "contour" because of following StandardError
#   Unknown type 'geometry(LineString,4326)' for column 'the_geom'

  create_table "counters", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "menus",      limit: 255
    t.string   "session_id", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "e900913", id: false, force: :cascade do |t|
    t.integer "srid"
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

  create_table "flightgps", id: false, force: :cascade do |t|
    t.string  "flightdate",     limit: 8
    t.string  "flightno",       limit: 2
    t.integer "id"
    t.float   "latitude"
    t.float   "longitude"
    t.float   "altitude"
    t.float   "speed"
    t.integer "timelimit"
    t.integer "yawdegree"
    t.integer "holdtime"
    t.integer "startdelay"
    t.integer "period"
    t.integer "repeattime"
    t.integer "repeatdistance"
    t.string  "turnmode"
  end

# Could not dump table "flightplan" because of following StandardError
#   Unknown type 'geometry(LineString,4326)' for column 'the_geom'

# Could not dump table "forest" because of following StandardError
#   Unknown type 'geometry(Polygon,4326)' for column 'wkb_geometry'

# Could not dump table "gg_province" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,3857)' for column 'the_geom'

# Could not dump table "hotspot" because of following StandardError
#   Unknown type 'geometry(Point,4326)' for column 'the_geom'

# Could not dump table "indextopo" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "indian", id: false, force: :cascade do |t|
    t.integer "srid"
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

# Could not dump table "kml" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "kml11", id: false, force: :cascade do |t|
    t.text "askml"
  end

# Could not dump table "landmark" because of following StandardError
#   Unknown type 'geometry(Point,4326)' for column 'the_geom'

# Could not dump table "line" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "locations", id: false, force: :cascade do |t|
    t.integer "id",        default: "nextval('locations_id_seq'::regclass)", null: false
    t.string  "loc_text"
    t.string  "loc_table"
    t.integer "loc_gid"
  end

  add_index "locations", ["loc_text"], name: "loc_text_ndx", using: :btree

# Could not dump table "mangrove_2530" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "mangrove_2543" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "mangrove_2552" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "muban" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "national_park" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_02_province" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_03_amphoe" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_04_tambon" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_06_muban" because of following StandardError
#   Unknown type 'geometry(Point,4326)' for column 'the_geom'

# Could not dump table "no_13_geology" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_14_mineral" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "no_22_spk" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "p", id: false, force: :cascade do |t|
    t.string  "prov_code", limit: 2
    t.string  "prov_name", limit: 49
    t.integer "id",                   default: "nextval('p_id_seq'::regclass)", null: false
  end

  create_table "pcode", id: false, force: :cascade do |t|
    t.string "prov_nam_t", limit: 49
    t.string "prov_code",  limit: 2
  end

  create_table "photos", id: false, force: :cascade do |t|
    t.integer "id",       default: "nextval('photos_id_seq'::regclass)", null: false
    t.string  "filename"
  end

# Could not dump table "point" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "point_layer" because of following StandardError
#   Unknown type 'geometry(Point,4326)' for column 'the_geom'

# Could not dump table "polygon_layer" because of following StandardError
#   Unknown type 'geometry(Polygon,4326)' for column 'geom'

  create_table "posts", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description"
    t.integer  "user_id"
    t.integer  "cnt_view"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "approved",    limit: 1
    t.integer  "approved_by"
  end

# Could not dump table "prov10" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "prov100" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

# Could not dump table "province" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "provinces", id: false, force: :cascade do |t|
    t.integer "id"
    t.string  "prov_code", limit: 2
    t.string  "prov_name", limit: 49
  end

# Could not dump table "reserve_forest" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

# Could not dump table "road" because of following StandardError
#   Unknown type 'geometry(MultiLineString,4326)' for column 'the_geom'

  create_table "spatial_ref_sys", primary_key: "srid", force: :cascade do |t|
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

# Could not dump table "testtopo" because of following StandardError
#   Unknown type 'geometry' for column 'the_geom'

  create_table "thaix", id: false, force: :cascade do |t|
    t.integer "srid"
    t.float   "minx"
    t.float   "miny"
    t.float   "maxx"
    t.float   "maxy"
  end

# Could not dump table "use_forest" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin",                  limit: 1
    t.string   "fname"
    t.string   "lname"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

# Could not dump table "utm_province" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,32647)' for column 'the_geom'

# Could not dump table "utm_wgs" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'the_geom'

end
