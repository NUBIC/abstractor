Given /^pathology cases with the following information exist$/ do |table|
  table.hashes.each_with_index do |pathology_case_hash, i|
    pathology_case = FactoryGirl.create(:pathology_case, note_text: pathology_case_hash['Note Text'], patient_id: pathology_case_hash['Patient ID'])
    pathology_case.abstract
    if pathology_case_hash['Status'] && pathology_case_hash['Status'] == 'Reviewed'
      abstractor_suggestion_status_accepted= AbstractorSuggestionStatus.where(:name => 'Accepted').first
      pathology_case.reload.abstractor_abstractions(true).each do |abstractor_abstraction|
        abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
          abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status_accepted
          abstractor_suggestion.save!
        end
      end
    end
  end
end