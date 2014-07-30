Given /^surgeries with the following information exist$/ do |table|
  table.hashes.each_with_index do |surgery_hash, i|
    surgery = FactoryGirl.create(:surgery, surg_case_id: surgery_hash['Surgery Case ID'], surg_case_nbr: surgery_hash['Surgery Case Number'], patient_id: surgery_hash['Patient ID'])
    surgery.abstract
  end
end