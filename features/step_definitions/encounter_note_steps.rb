Given /^encounter notes with the following information exist$/ do |table|
  table.hashes.each_with_index do |encounter_note_hash, i|
    encounter_note = FactoryGirl.create(:encounter_note, note_text: encounter_note_hash['Note Text'])
    encounter_note.abstract
    if encounter_note_hash['Status'] && encounter_note_hash['Status'] == 'Reviewed'
      abstractor_suggestion_status_accepted= AbstractorSuggestionStatus.where(:name => 'Accepted').first
      encounter_note.reload.abstractor_abstractions(true).each do |abstractor_abstraction|
        abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
          abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status_accepted
          abstractor_suggestion.save!
        end
      end
    end
  end
end

Given /^encounter note(?: with text "([^"]*)")? exists$/ do |text|
  encounter = FactoryGirl.create(:epic_encounter)
  text ||= "Hello, I have no idea what is your KPS."
  note = FactoryGirl.create(:epic_encounter_note, encounter_row_src_id: encounter.id, note_text: text)
end

Given /^last encounter note has abstraction$/ do
  note = EncounterNote.last
  schema = AbstractorAbstractionSchema.where(:predicate => 'has_karnofsky_performance_status').first
  abstractor_subject = AbstractorSubject.where(:subject_type => 'EncounterNote', abstractor_abstraction_schema_id: schema.id).first
  abstractor_abstraction = AbstractorAbstraction.create!(abstractor_subject: abstractor_subject, subject_id: note.id)
end

Given /^last encounter note abstraction has(?: (accepted|rejected))? (unknown|not applicable) suggestion(?: with match value "([^"]*)")?$/ do |status, applicable_case, match_value|
  set_abstractor_suggestion_for_object(EncounterNote.last, status, applicable_case, nil, match_value)
end

Given /^last encounter note abstraction has(?: (accepted|rejected))? suggestion with value "([^"]*)"(?: and with match value(?:s)? "([^"]*)")?$/ do |status, value, match_values|
  set_abstractor_suggestion_for_object(EncounterNote.last, status, nil, value, match_values)
end

