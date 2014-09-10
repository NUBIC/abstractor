class ImagingExam < ActiveRecord::Base
  include Abstractor::Abstractable
  # attr_accessible :note_text, :patient_id, :report_date, :accession_number

  def source_name_method
    "#{accession_number} (#{report_date})"
  end
end