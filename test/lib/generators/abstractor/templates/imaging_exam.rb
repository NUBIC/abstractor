class ImagingExam < ActiveRecord::Base
  include Abstractor::Abstractable
  attr_accessible :note_text

  def surgeries_dynamic_list_method
    [{ id: '123' , value: '123 (1/1/2014)' }, { id: '456' , value: '456 (7/1/2014)' }]
  end

  def surgery_suggestions
    ['456']
  end
end