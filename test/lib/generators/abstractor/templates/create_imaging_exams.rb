class CreateImagingExams < ActiveRecord::Migration
  def change
    create_table :imaging_exams do |t|
      t.text      :note_text, :null => false
      t.timestamps
    end
  end
end
