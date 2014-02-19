class CreateSiteCategories < ActiveRecord::Migration
  def change
    create_table "site_categories_sites", :id => false, :force => true do |t|
      t.integer "site_id"
      t.integer "site_category_id"
    end

    create_table "site_categories", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at", :null => false
      t.datetime "updated_at"
    end
  end
end