class Surgery < ActiveRecord::Base
  has_many :surgical_procedures, primary_key: :surg_case_id, foreign_key: :surg_case_id
  include Abstractor::Abstractable
  # attr_accessible :surg_case_id, :surg_case_nbr, :patient_id

  def patient_imaging_exams
    { source_type: ImagingExam.to_s, source_method: 'note_text', sources: ImagingExam.where(patient_id: patient_id), source_name_method: 'source_name_method'  }
  end

  def patient_surgical_procedure_reports
    { source_type: SurgicalProcedureReport.to_s, source_method: 'note_text', sources: SurgicalProcedureReport.where(patient_id: patient_id), source_name_method: 'source_name_method' }
  end

  def surgical_procedure_notes
    sources = []
    surgical_procedures.each do |surgical_procedure|
      sources << { source_type: SurgicalProcedure, source_id: surgical_procedure.id, source_method: 'modifier' }
      sources << { source_type: SurgicalProcedure, source_id: surgical_procedure.id, source_method: 'description' }
    end
    sources
  end
end