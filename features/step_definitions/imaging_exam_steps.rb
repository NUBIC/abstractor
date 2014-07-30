Given /^imaging exams with the following information exist$/ do |table|
  table.hashes.each_with_index do |imaging_exam_hash, i|
    imaging_exam = FactoryGirl.create(:imaging_exam, note_text: imaging_exam_hash['Note Text'], patient_id: imaging_exam_hash['Patient ID'], report_date: Date.parse(imaging_exam_hash['Date']), accession_number: imaging_exam_hash['Accession Number'])
  end
end
