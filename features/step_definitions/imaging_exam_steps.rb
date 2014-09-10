Given /^imaging exams with the following information exist$/ do |table|
  table.hashes.each_with_index do |imaging_exam_hash, i|
    imaging_exam = FactoryGirl.create(:imaging_exam, note_text: imaging_exam_hash['Note Text'], patient_id: imaging_exam_hash['Patient ID'], report_date: Date.parse(imaging_exam_hash['Date']), accession_number: imaging_exam_hash['Accession Number'])
    imaging_exam.abstract(namespace_type: imaging_exam_hash['Namespace'], namespace_id: imaging_exam_hash['Namespace ID'].to_i)
  end
end

When /^imaging exam with accession number "(.*?)" is abstracted under namespace_type "(.*?)" and namespace_id (\d+)$/ do |accession_number, namespace_type, namespace_id|
  imaging_exam = ImagingExam.where(accession_number: accession_number).first
  imaging_exam.abstract(namespace_type: namespace_type, namespace_id: namespace_id.to_i)
end