class SurgicalProcedure < ActiveRecord::Base
  attr_accessible :surg_case_id, :description, :modifier
end