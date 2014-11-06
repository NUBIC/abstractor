class CreateMoomins < ActiveRecord::Migration
  def change
    create_table :moomins do |t|
      t.text      :note_text, :null => false
      t.timestamps
    end
  end
end