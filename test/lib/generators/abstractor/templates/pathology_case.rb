class PathologyCase < ActiveRecord::Base
  include Abstractor::Abstractable
  # attr_accessible :note_text, :patient_id

  def patient_surgeries
    Surgery.where(patient_id: patient_id).map { |s| { id: s.surg_case_id, value: s.surg_case_nbr }  }
  end
end