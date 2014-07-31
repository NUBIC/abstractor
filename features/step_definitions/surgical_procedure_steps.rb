Given /^surgical procedures with the following information exist$/ do |table|
  table.hashes.each_with_index do |surgical_procedure_hash, i|
    surgical_procedure = FactoryGirl.create(:surgical_procedure, surg_case_id: surgical_procedure_hash['Surgery Case ID'], description: surgical_procedure_hash['Description'], modifier: surgical_procedure_hash['Modifier'])
  end
end