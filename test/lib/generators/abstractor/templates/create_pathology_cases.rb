class CreatePathologyCases < ActiveRecord::Migration
  def change
    create_table :pathology_cases do |t|
      t.text        :note_text,   null: false
      t.integer     :patient_id,  null: false
      t.timestamps
    end
  end
end
