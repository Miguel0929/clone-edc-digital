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

ActiveRecord::Schema.define(version: 20191112225230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_grants", force: :cascade do |t|
    t.string   "code"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "access_token_expires_at"
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.integer  "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.json     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["name", "time"], name: "index_ahoy_events_on_name_and_time", using: :btree
  add_index "ahoy_events", ["user_id", "name"], name: "index_ahoy_events_on_user_id_and_name", using: :btree
  add_index "ahoy_events", ["visit_id", "name"], name: "index_ahoy_events_on_visit_id_and_name", using: :btree

  create_table "answers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.text     "answer_text"
    t.integer  "rubric_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["answer_text"], name: "index_answers_on_answer_text", using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "async_jobs", force: :cascade do |t|
    t.string   "title"
    t.integer  "progress"
    t.integer  "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "file"
    t.string   "label"
    t.integer  "document_type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attempts", force: :cascade do |t|
    t.integer  "quiz_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "attempts", ["quiz_id"], name: "index_attempts_on_quiz_id", using: :btree
  add_index "attempts", ["user_id"], name: "index_attempts_on_user_id", using: :btree

  create_table "certificate_templates", force: :cascade do |t|
    t.string   "name"
    t.string   "file"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "main",       default: false
  end

  create_table "certificates", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "file"
    t.integer  "certificate_template_id"
    t.string   "batch"
    t.string   "date"
    t.integer  "mailing_status",          default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "program"
    t.string   "route"
  end

  create_table "chapter_contents", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "coursable_id"
    t.string  "coursable_type"
    t.integer "position"
  end

  create_table "chapters", force: :cascade do |t|
    t.string   "name"
    t.integer  "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points"
    t.integer  "position"
    t.boolean  "manual_points", default: false
  end

  add_index "chapters", ["program_id"], name: "index_chapters_on_program_id", using: :btree

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "app_id"
    t.string   "app_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_notifications", force: :cascade do |t|
    t.integer "comment_id"
    t.integer "user_id"
  end

  add_index "comment_notifications", ["comment_id"], name: "index_comment_notifications_on_comment_id", using: :btree
  add_index "comment_notifications", ["user_id"], name: "index_comment_notifications_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "answer_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",    default: false
    t.integer  "question_id"
    t.integer  "owner_id"
  end

  create_table "delireverable_packages", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tipo"
  end

  create_table "delireverable_users", force: :cascade do |t|
    t.integer  "delireverable_id"
    t.integer  "user_id"
    t.string   "file"
    t.text     "comments"
    t.integer  "status",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delireverable_users", ["delireverable_id"], name: "index_delireverable_users_on_delireverable_id", using: :btree
  add_index "delireverable_users", ["user_id"], name: "index_delireverable_users_on_user_id", using: :btree

  create_table "delireverables", force: :cascade do |t|
    t.integer  "delireverable_package_id"
    t.string   "name"
    t.text     "description"
    t.string   "file"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "evaluation_refilables", force: :cascade do |t|
    t.integer  "template_refilable_id"
    t.string   "name"
    t.integer  "points"
    t.string   "excelent"
    t.string   "good"
    t.string   "regular"
    t.string   "bad"
    t.integer  "position"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "evaluation_refilables", ["template_refilable_id"], name: "index_evaluation_refilables_on_template_refilable_id", using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.integer "chapter_id"
    t.string  "name"
    t.integer "points"
    t.string  "excelent"
    t.string  "good"
    t.string  "regular"
    t.string  "bad"
    t.integer "position"
  end

  create_table "exporters", force: :cascade do |t|
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "frequent_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
  end

  create_table "frequents", force: :cascade do |t|
    t.text     "name"
    t.text     "answer"
    t.boolean  "featured"
    t.integer  "frequent_category_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "glossaries", force: :cascade do |t|
    t.string   "term"
    t.text     "definition"
    t.string   "image"
    t.integer  "glossary_category_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "glossaries", ["glossary_category_id"], name: "index_glossaries_on_glossary_category_id", using: :btree

  create_table "glossary_categories", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_delireverable_packages", force: :cascade do |t|
    t.integer "group_id"
    t.integer "delireverable_package_id"
  end

  add_index "group_delireverable_packages", ["delireverable_package_id"], name: "index_group_delireverable_packages_on_delireverable_package_id", using: :btree
  add_index "group_delireverable_packages", ["group_id"], name: "index_group_delireverable_packages_on_group_id", using: :btree

  create_table "group_programs", force: :cascade do |t|
    t.integer "group_id"
    t.integer "program_id"
    t.integer "position"
  end

  add_index "group_programs", ["group_id"], name: "index_group_programs_on_group_id", using: :btree
  add_index "group_programs", ["program_id"], name: "index_group_programs_on_program_id", using: :btree

  create_table "group_quizzes", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "quiz_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "group_quizzes", ["group_id"], name: "index_group_quizzes_on_group_id", using: :btree
  add_index "group_quizzes", ["quiz_id"], name: "index_group_quizzes_on_quiz_id", using: :btree

  create_table "group_stats", force: :cascade do |t|
    t.integer  "group_students"
    t.float    "average_progress"
    t.float    "average_seen"
    t.integer  "evaluated_students"
    t.integer  "unevaluated_studets"
    t.integer  "group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "group_stats", ["group_id"], name: "index_group_stats_on_group_id", using: :btree

  create_table "group_template_refilables", force: :cascade do |t|
    t.integer "group_id"
    t.integer "template_refilable_id"
  end

  add_index "group_template_refilables", ["group_id"], name: "index_group_template_refilables_on_group_id", using: :btree
  add_index "group_template_refilables", ["template_refilable_id"], name: "index_group_template_refilables_on_template_refilable_id", using: :btree

  create_table "group_users", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "group_users", ["group_id"], name: "index_group_users_on_group_id", using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "key"
    t.datetime "deleted_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "state_id"
    t.string   "category"
    t.integer  "university_id"
    t.integer  "learning_path_id"
    t.integer  "learning_path2_id"
    t.boolean  "financiero"
    t.boolean  "trial",             default: false, null: false
    t.integer  "group_premium_id"
  end

  add_index "groups", ["deleted_at"], name: "index_groups_on_deleted_at", using: :btree
  add_index "groups", ["learning_path2_id"], name: "index_groups_on_learning_path2_id", using: :btree
  add_index "groups", ["learning_path_id"], name: "index_groups_on_learning_path_id", using: :btree
  add_index "groups", ["university_id"], name: "index_groups_on_university_id", using: :btree

  create_table "industries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "key_questions", force: :cascade do |t|
    t.integer  "coursable_id"
    t.integer  "chapter_content_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "key_questions", ["chapter_content_id"], name: "index_key_questions_on_chapter_content_id", using: :btree

  create_table "learning_path_contents", force: :cascade do |t|
    t.integer  "learning_path_id"
    t.integer  "content_id"
    t.string   "content_type"
    t.integer  "position"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "learning_path_contents", ["learning_path_id"], name: "index_learning_path_contents_on_learning_path_id", using: :btree

  create_table "learning_path_notifications", force: :cascade do |t|
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "learning_path_notifications", ["group_id"], name: "index_learning_path_notifications_on_group_id", using: :btree

  create_table "learning_path_programs", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "learning_path_id"
    t.integer  "position"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "learning_path_programs", ["learning_path_id"], name: "index_learning_path_programs_on_learning_path_id", using: :btree
  add_index "learning_path_programs", ["program_id"], name: "index_learning_path_programs_on_program_id", using: :btree

  create_table "learning_paths", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "tipo"
  end

  create_table "lessons", force: :cascade do |t|
    t.string   "identifier"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "video_url"
  end

  create_table "mailbox_attachments", force: :cascade do |t|
    t.string   "file"
    t.string   "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "is_delivered",               default: false
    t.string   "delivery_method"
    t.string   "message_id"
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "mentor_helps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "sender"
  end

  create_table "mentor_program_notifications", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "user_id"
    t.integer  "notification_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "mentor_program_notifications", ["program_id"], name: "index_mentor_program_notifications_on_program_id", using: :btree
  add_index "mentor_program_notifications", ["user_id"], name: "index_mentor_program_notifications_on_user_id", using: :btree

  create_table "mentor_question_notifications", force: :cascade do |t|
    t.integer  "chapter_content_id"
    t.integer  "user_id"
    t.integer  "notification_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "mentor_question_notifications", ["chapter_content_id"], name: "index_mentor_question_notifications_on_chapter_content_id", using: :btree
  add_index "mentor_question_notifications", ["user_id"], name: "index_mentor_question_notifications_on_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notificable_id"
    t.string   "notificable_type"
    t.boolean  "read",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "panel_notifications", force: :cascade do |t|
    t.integer  "notification"
    t.integer  "user_id"
    t.boolean  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "panel_notifications", ["user_id"], name: "index_panel_notifications_on_user_id", using: :btree

  create_table "program_actives", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "program_id"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "program_actives", ["program_id"], name: "index_program_actives_on_program_id", using: :btree
  add_index "program_actives", ["user_id"], name: "index_program_actives_on_user_id", using: :btree

  create_table "program_attachments", force: :cascade do |t|
    t.string   "file"
    t.string   "label"
    t.integer  "document_type"
    t.string   "name"
    t.integer  "program_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "program_attachments", ["program_id"], name: "index_program_attachments_on_program_id", using: :btree

  create_table "program_notifications", force: :cascade do |t|
    t.integer "program_id"
    t.integer "notification_type"
  end

  add_index "program_notifications", ["program_id"], name: "index_program_notifications_on_program_id", using: :btree

  create_table "program_sequences", force: :cascade do |t|
    t.string  "sequence"
    t.integer "group_id"
  end

  add_index "program_sequences", ["group_id"], name: "index_program_sequences_on_group_id", using: :btree

  create_table "program_stats", force: :cascade do |t|
    t.integer  "checked",           default: 0
    t.integer  "user_id"
    t.integer  "program_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.float    "program_progress",  default: 0.0
    t.float    "program_seen",      default: 0.0
    t.integer  "last_content"
    t.datetime "evaluation_date"
    t.string   "evaluating_mentor"
    t.string   "sending_method"
    t.float    "score",             default: 0.0
    t.boolean  "sent_certificate",  default: false
  end

  add_index "program_stats", ["program_id"], name: "index_program_stats_on_program_id", using: :btree
  add_index "program_stats", ["user_id"], name: "index_program_stats_on_user_id", using: :btree

  create_table "programs", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "cover"
    t.datetime "deleted_at"
    t.integer  "position"
    t.string   "category"
    t.text     "objetive"
    t.text     "curriculum"
    t.string   "icon"
    t.string   "video"
    t.string   "color"
    t.string   "small_cover"
    t.integer  "level"
    t.integer  "tipo"
    t.integer  "content_type"
    t.string   "short_name"
  end

  add_index "programs", ["deleted_at"], name: "index_programs_on_deleted_at", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer  "question_type",  default: 0
    t.string   "question_text"
    t.integer  "position"
    t.text     "answer_options"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "support_text"
    t.integer  "points"
    t.string   "support_image"
  end

  create_table "queue_notifications", force: :cascade do |t|
    t.integer "category"
    t.integer "program"
    t.text    "groups"
    t.string  "url"
    t.string  "detail"
    t.boolean "sent",     default: false
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "quiz_question_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "answer_text"
    t.boolean  "correct"
  end

  add_index "quiz_answers", ["quiz_question_id"], name: "index_quiz_answers_on_quiz_question_id", using: :btree
  add_index "quiz_answers", ["user_id"], name: "index_quiz_answers_on_user_id", using: :btree

  create_table "quiz_questions", force: :cascade do |t|
    t.integer  "question_type"
    t.string   "question_text"
    t.integer  "position"
    t.text     "answer_options"
    t.text     "support_text"
    t.integer  "points"
    t.integer  "quiz_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "quiz_questions", ["quiz_id"], name: "index_quiz_questions_on_quiz_id", using: :btree

  create_table "quizzes", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "tipo"
    t.integer  "program_id"
  end

  add_index "quizzes", ["program_id"], name: "index_quizzes_on_program_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.float    "rank"
    t.integer  "user_id"
    t.integer  "ratingable_id"
    t.string   "ratingable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "ratings", ["ratingable_type", "ratingable_id"], name: "index_ratings_on_ratingable_type_and_ratingable_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "receptions", force: :cascade do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "receptions", ["group_id"], name: "index_receptions_on_group_id", using: :btree

  create_table "refilable_default_comments", force: :cascade do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "template_refilable_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "refilable_default_comments", ["template_refilable_id"], name: "index_refilable_default_comments_on_template_refilable_id", using: :btree

  create_table "refilable_notifications", force: :cascade do |t|
    t.integer  "template_refilable_id"
    t.integer  "notification_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "refilable_notifications", ["template_refilable_id"], name: "index_refilable_notifications_on_template_refilable_id", using: :btree

  create_table "refilables", force: :cascade do |t|
    t.integer  "template_refilable_id"
    t.integer  "user_id"
    t.text     "content"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mentor_id"
    t.integer  "points"
    t.boolean  "draft",                 default: false
  end

  add_index "refilables", ["template_refilable_id"], name: "index_refilables_on_template_refilable_id", using: :btree
  add_index "refilables", ["user_id"], name: "index_refilables_on_user_id", using: :btree

  create_table "report_notifications", force: :cascade do |t|
    t.integer  "report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "report_notifications", ["report_id"], name: "index_report_notifications_on_report_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "cause"
    t.boolean  "status"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
  end

  add_index "reports", ["reportable_type", "reportable_id"], name: "index_reports_on_reportable_type_and_reportable_id", using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "route_covers", force: :cascade do |t|
    t.string   "name"
    t.string   "route_image"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "route_texts", force: :cascade do |t|
    t.string   "name"
    t.text     "redaction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rubrics", force: :cascade do |t|
    t.string  "criteria"
    t.text    "base"
    t.integer "question_id"
  end

  add_index "rubrics", ["question_id"], name: "index_rubrics_on_question_id", using: :btree

  create_table "score_student_stats", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "rango1"
    t.integer  "rango2"
    t.integer  "rango3"
    t.integer  "rango4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "tipo"
  end

  add_index "score_student_stats", ["program_id"], name: "index_score_student_stats_on_program_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "browser"
    t.string   "platform"
    t.string   "device_type"
    t.datetime "start"
    t.datetime "finish"
  end

  create_table "shared_attachments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "file"
    t.string   "label"
    t.integer  "document_type"
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_group_attachment_groups", force: :cascade do |t|
    t.integer "shared_group_attachment_id"
    t.integer "group_id"
  end

  create_table "shared_group_attachment_notifications", force: :cascade do |t|
    t.integer  "shared_group_attachment_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "shared_group_attachment_notifications", ["shared_group_attachment_id"], name: "index_share_group_attachment_notifications", using: :btree

  create_table "shared_group_attachments", force: :cascade do |t|
    t.string   "file"
    t.string   "label"
    t.integer  "document_type"
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "slug"
  end

  create_table "student_evaluated_points_state_mentors", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "state_id"
    t.integer  "mentor_id"
    t.integer  "tipo"
    t.integer  "puntaje_90_100"
    t.integer  "puntaje_80_89"
    t.integer  "puntaje_60_79"
    t.integer  "puntaje_0_59"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "student_evaluated_points_state_mentors", ["mentor_id"], name: "index_student_evaluated_points_state_mentors_on_mentor_id", using: :btree
  add_index "student_evaluated_points_state_mentors", ["program_id"], name: "index_student_evaluated_points_state_mentors_on_program_id", using: :btree
  add_index "student_evaluated_points_state_mentors", ["state_id"], name: "index_student_evaluated_points_state_mentors_on_state_id", using: :btree
  add_index "student_evaluated_points_state_mentors", ["tipo"], name: "index_student_evaluated_points_state_mentors_on_tipo", using: :btree

  create_table "student_evaluated_points_states", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "state_id"
    t.integer  "tipo"
    t.integer  "puntaje_90_100"
    t.integer  "puntaje_80_89"
    t.integer  "puntaje_60_79"
    t.integer  "puntaje_0_59"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "student_evaluated_points_states", ["program_id"], name: "index_student_evaluated_points_states_on_program_id", using: :btree
  add_index "student_evaluated_points_states", ["state_id"], name: "index_student_evaluated_points_states_on_state_id", using: :btree
  add_index "student_evaluated_points_states", ["tipo"], name: "index_student_evaluated_points_states_on_tipo", using: :btree

  create_table "student_evaluated_states", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "state_id"
    t.integer  "total"
    t.integer  "evaluados"
    t.integer  "no_evaluados"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "student_evaluated_states", ["program_id"], name: "index_student_evaluated_states_on_program_id", using: :btree
  add_index "student_evaluated_states", ["state_id"], name: "index_student_evaluated_states_on_state_id", using: :btree

  create_table "student_evaluateds", force: :cascade do |t|
    t.integer  "program_id"
    t.integer  "total"
    t.integer  "evaluados"
    t.integer  "no_evaluados"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "student_evaluateds", ["program_id"], name: "index_student_evaluateds_on_program_id", using: :btree

  create_table "students_states_coaches", force: :cascade do |t|
    t.integer  "state_id"
    t.integer  "coach_id"
    t.integer  "total"
    t.boolean  "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "students_states_coaches", ["coach_id"], name: "index_students_states_coaches_on_coach_id", using: :btree
  add_index "students_states_coaches", ["state_id"], name: "index_students_states_coaches_on_state_id", using: :btree

  create_table "template_refilables", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.text     "content"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tipo"
    t.integer  "program_id"
  end

  add_index "template_refilables", ["program_id"], name: "index_template_refilables_on_program_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "element_id"
    t.integer  "coach_id"
    t.integer  "trainee_id"
    t.integer  "category"
    t.string   "title"
    t.boolean  "closed",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "trackers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "chapter_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trackers", ["chapter_content_id"], name: "index_trackers_on_chapter_content_id", using: :btree
  add_index "trackers", ["user_id"], name: "index_trackers_on_user_id", using: :btree

  create_table "universities", force: :cascade do |t|
    t.string   "name"
    t.integer  "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "universities", ["state_id"], name: "index_universities_on_state_id", using: :btree

  create_table "user_codes", force: :cascade do |t|
    t.string   "codigo"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_codes", ["user_id"], name: "index_user_codes_on_user_id", using: :btree

  create_table "user_details", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "birthdate"
    t.string   "situation"
    t.string   "interest"
    t.text     "challenge"
    t.text     "goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_details", ["user_id"], name: "index_user_details_on_user_id", using: :btree

  create_table "user_evaluation_refilables", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "evaluation_refilable_id"
    t.integer  "points"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "refilable_id"
  end

  add_index "user_evaluation_refilables", ["evaluation_refilable_id"], name: "index_user_evaluation_refilables_on_evaluation_refilable_id", using: :btree
  add_index "user_evaluation_refilables", ["refilable_id"], name: "index_user_evaluation_refilables_on_refilable_id", using: :btree
  add_index "user_evaluation_refilables", ["user_id"], name: "index_user_evaluation_refilables_on_user_id", using: :btree

  create_table "user_evaluations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "evaluation_id"
    t.integer "points"
  end

  create_table "user_trackers", force: :cascade do |t|
    t.integer  "old_group"
    t.integer  "user_id"
    t.string   "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_trainees", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "trainee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",                                                                              null: false
    t.string   "encrypted_password",                default: "",                                                                              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,                                                                               null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.datetime "created_at",                                                                                                                  null: false
    t.datetime "updated_at",                                                                                                                  null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                 default: 0
    t.integer  "role",                              default: 0
    t.datetime "deleted_at"
    t.integer  "group_id"
    t.text     "bio"
    t.integer  "gender"
    t.string   "state"
    t.string   "city"
    t.string   "profile_picture"
    t.string   "provider"
    t.string   "uid"
    t.string   "authentication_token",   limit: 30
    t.integer  "industry_id"
    t.integer  "evaluation_status",                 default: 0
    t.boolean  "banned",                            default: false
    t.boolean  "video_trigger",                     default: true
    t.float    "user_progress",                     default: 0.0
    t.float    "user_seen",                         default: 0.0
    t.boolean  "check_ready"
    t.text     "tour_trigger",                      default: "---\n:first: true\n:second: true\n:third: true\n:fourth: true\n:fifth: true\n"
    t.datetime "evaluation_date"
    t.string   "evaluating_mentor"
    t.integer  "coach_id"
    t.string   "curp",                   limit: 18
    t.boolean  "premium",                           default: true,                                                                            null: false
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["industry_id"], name: "index_users_on_industry_id", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "visits", force: :cascade do |t|
    t.string   "visit_token"
    t.string   "visitor_token"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree
  add_index "visits", ["visit_token"], name: "index_visits_on_visit_token", unique: true, using: :btree

  add_foreign_key "attempts", "quizzes"
  add_foreign_key "attempts", "users"
  add_foreign_key "evaluation_refilables", "template_refilables"
  add_foreign_key "glossaries", "glossary_categories"
  add_foreign_key "group_quizzes", "groups"
  add_foreign_key "group_quizzes", "quizzes"
  add_foreign_key "group_stats", "groups"
  add_foreign_key "groups", "learning_paths"
  add_foreign_key "groups", "universities"
  add_foreign_key "key_questions", "chapter_contents"
  add_foreign_key "learning_path_contents", "learning_paths"
  add_foreign_key "learning_path_notifications", "groups"
  add_foreign_key "learning_path_programs", "learning_paths"
  add_foreign_key "learning_path_programs", "programs"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "mentor_program_notifications", "programs"
  add_foreign_key "mentor_program_notifications", "users"
  add_foreign_key "mentor_question_notifications", "chapter_contents"
  add_foreign_key "mentor_question_notifications", "users"
  add_foreign_key "panel_notifications", "users"
  add_foreign_key "program_actives", "programs"
  add_foreign_key "program_actives", "users"
  add_foreign_key "program_attachments", "programs"
  add_foreign_key "program_sequences", "groups"
  add_foreign_key "program_stats", "programs"
  add_foreign_key "program_stats", "users"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_answers", "users"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "programs"
  add_foreign_key "ratings", "users"
  add_foreign_key "receptions", "groups"
  add_foreign_key "refilable_default_comments", "template_refilables"
  add_foreign_key "report_notifications", "reports"
  add_foreign_key "reports", "users"
  add_foreign_key "shared_group_attachment_notifications", "shared_group_attachments"
  add_foreign_key "template_refilables", "programs"
  add_foreign_key "universities", "states"
  add_foreign_key "user_codes", "users"
  add_foreign_key "user_details", "users"
  add_foreign_key "user_evaluation_refilables", "evaluation_refilables"
  add_foreign_key "user_evaluation_refilables", "refilables"
  add_foreign_key "user_evaluation_refilables", "users"
  add_foreign_key "user_trainees", "users"
  add_foreign_key "user_trainees", "users", column: "trainee_id"
  add_foreign_key "users", "industries"
  add_foreign_key "users", "users", column: "coach_id"
end
