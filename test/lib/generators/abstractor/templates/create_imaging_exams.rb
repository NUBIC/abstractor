class CreateImagingExams < ActiveRecord::Migration
  def change
    create_table :imaging_exams do |t|
      t.text        :note_text,         null: false
      t.integer     :patient_id,        null: false
      t.date        :report_date,       null: false
      t.string      :accession_number,  null: false
      t.timestamps
    end
  end
end