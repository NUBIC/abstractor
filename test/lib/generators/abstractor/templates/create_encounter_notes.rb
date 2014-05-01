class CreateEncounterNotes < ActiveRecord::Migration
  def change
    create_table :encounter_notes do |t|
      t.text      :note_text, :null => false
      t.timestamps
    end
  end
end
