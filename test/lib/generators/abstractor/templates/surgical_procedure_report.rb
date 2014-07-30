class SurgicalProcedureReport < ActiveRecord::Base
  attr_accessible :note_text, :patient_id, :report_date, :reference_number

  def source_name_method
    "#{reference_number} (#{report_date})"
  end
end