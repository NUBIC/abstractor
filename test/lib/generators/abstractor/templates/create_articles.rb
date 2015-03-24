class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.text        :note_text,   null: false
      t.timestamps
    end
  end
end
