Given /^radiation therapy prescriptions with the following information exist$/ do |table|
  table.hashes.each_with_index do |radiation_therapy_prescription_hash, i|
    radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: radiation_therapy_prescription_hash['Site'])
    radiation_therapy_prescription.abstract
    if radiation_therapy_prescription_hash['Status'] && radiation_therapy_prescription_hash['Status'] == 'Reviewed'
      abstractor_suggestion_status_accepted= AbstractorSuggestionStatus.where(:name => 'Accepted').first
      radiation_therapy_prescription.reload.abstractor_abstractions(true).each do |abstractor_abstraction|
        abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
          abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status_accepted
          abstractor_suggestion.save!
        end
      end
    end
  end
end

Given /^radiation therapy prescription(?: with site "([^"]*)")? exists$/ do |text|
  radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, :site_name => text )
end

Given /^last radiation therapy prescription has anatomical location abstraction$/ do
  radiation_therapy_prescription = RadiationTherapyPrescription.last
  schema = AbstractorAbstractionSchema.where(:predicate => 'has_anatomical_location').first
  abstractor_subject = AbstractorSubject.where(:subject_type => 'RadiationTherapyPrescription', abstractor_abstraction_schema_id: schema.id).first
  abstractor_abstraction = AbstractorAbstraction.create!(abstractor_subject: abstractor_subject, subject_id: radiation_therapy_prescription.id)

  abstraction_group = AbstractorAbstractionGroup.create(abstractor_subject_group: abstractor_subject.abstractor_subject_group, subject: radiation_therapy_prescription)

  AbstractorAbstractionGroupMember.create(:abstractor_abstraction_group => abstraction_group, :abstractor_abstraction => abstractor_abstraction)
end

Given /^last radiation therapy prescription abstraction has(?: (accepted|rejected))? (unknown|not applicable) suggestion(?: with match value "([^"]*)")?$/ do |status, applicable_case, match_value|
  set_abstractor_suggestion_for_object(RadiationTherapyPrescription.last, status, applicable_case, nil, match_value)
end

Given /^last radiation therapy prescription abstraction has(?: (accepted|rejected))? suggestion with value "([^"]*)"(?: and with match value(?:s)? "([^"]*)")?$/ do |status, value, match_values|
  set_abstractor_suggestion_for_object(RadiationTherapyPrescription.last, status, nil, value, match_values)
end