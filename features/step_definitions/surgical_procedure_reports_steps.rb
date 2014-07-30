Given /^surgical procedure reports with the following information exist$/ do |table|
  table.hashes.each_with_index do |surgical_procedure_report_hash, i|
    surgical_procedure_report = FactoryGirl.create(:surgical_procedure_report, note_text: surgical_procedure_report_hash['Note Text'], patient_id: surgical_procedure_report_hash['Patient ID'], report_date: Date.parse(surgical_procedure_report_hash['Date']), reference_number: surgical_procedure_report_hash['Reference Number'])
  end
end
