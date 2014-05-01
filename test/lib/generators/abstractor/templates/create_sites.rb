class CreateSites < ActiveRecord::Migration
  def change
    create_table "sites", :force => true do |t|
      t.string   "icdo3_code", :null => false
      t.integer  "level",      :null => false
      t.string   "name",       :null => false
      t.boolean  "synonym",    :null => false
      t.boolean  "laterality"
      t.datetime "created_at", :null => false
      t.datetime "updated_at"
    end
  end
end
