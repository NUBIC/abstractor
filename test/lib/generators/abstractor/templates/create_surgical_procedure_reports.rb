class CreateSurgicalProcedureReports < ActiveRecord::Migration
  def change
    create_table :surgical_procedure_reports do |t|
      t.text        :note_text,         null: false
      t.integer     :patient_id,        null: false
      t.date        :report_date,       null: false
      t.string      :reference_number,  null: false
      t.timestamps
    end
  end
end
