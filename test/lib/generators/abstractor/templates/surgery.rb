class Surgery < ActiveRecord::Base
  include Abstractor::Abstractable
  attr_accessible :surg_case_id, :surg_case_nbr, :patient_id

  def patient_imaging_exams
    { source_type: ImagingExam.to_s, source_method: 'note_text', sources: ImagingExam.where(patient_id: patient_id), source_name_method: 'source_name_method'  }
  end

  def patient_surgical_procedure_reports
    { source_type: SurgicalProcedureReport.to_s, source_method: 'note_text', sources: SurgicalProcedureReport.where(patient_id: patient_id), source_name_method: 'source_name_method' }
  end
end