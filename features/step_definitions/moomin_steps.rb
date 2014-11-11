Given(/^moomin abstraction schemas have return note on empty section set to "(.*?)"$/) do |empty_section|
  abstractor_section = Abstractor::AbstractorSection.where(source_type: 'Moomin', source_method: 'note_text', name: 'favorite moomin').first
  if empty_section == "true"
    abstractor_section.return_note_on_empty_section = true
  else
    abstractor_section.return_note_on_empty_section = false
  end
  abstractor_section.save!
end

Given /^moomin abstraction schemas are set with no sections$/ do
  Abstractor::Setup.system
  setup_moomin_abstraction_schemas
  value_rule_type = Abstractor::AbstractorRuleType.where(name: 'value').first
  source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
  Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: value_rule_type, abstractor_abstraction_source_type: source_type_nlp_suggestion)
end

Given /^moomin abstraction schemas are set with a section$/ do
  Abstractor::Setup.system
  setup_moomin_abstraction_schemas
  value_rule_type = Abstractor::AbstractorRuleType.where(name: 'value').first
  source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
  abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first
  abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'Moomin', source_method: 'note_text', name: 'favorite moomin', delimiter: ':')
  abstractor_section_name_varaint = Abstractor::AbstractorSectionNameVariant.create(abstractor_section: abstractor_section, name: 'beloved moomin')
  Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: value_rule_type, abstractor_abstraction_source_type: source_type_nlp_suggestion, section_name: 'favorite moomin')
end

Given /^moomin abstraction schemas are set with a custom section$/ do
  Abstractor::Setup.system
  setup_moomin_abstraction_schemas
  value_rule_type = Abstractor::AbstractorRuleType.where(name: 'value').first
  source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
  abstractor_section_type_custom = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_CUSTOM).first
  abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_custom, source_type: 'Moomin', source_method: 'note_text', name: 'favorite moomin', custom_regular_expression: "(?<=^|[\r\n])([A-Z][^delimiter]*)delimiter([^\r\n]*(?:[\r\n]+(?![A-Z].*delimiter).*)*)", delimiter: ':')
  abstractor_section_name_varaint = Abstractor::AbstractorSectionNameVariant.create(abstractor_section: abstractor_section, name: 'beloved moomin')
  Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: value_rule_type, abstractor_abstraction_source_type: source_type_nlp_suggestion, section_name: 'favorite moomin')
end

Given /^moomins with the following information exist$/ do |table|
  table.hashes.each_with_index do |moomin_hash, i|
    moomin = FactoryGirl.create(:moomin, note_text: moomin_hash['Note Text'])
    moomin.abstract
    if moomin_hash['Status'] && moomin_hash['Status'] == 'Reviewed'
      abstractor_suggestion_status_accepted= AbstractorSuggestionStatus.where(:name => 'Accepted').first
      moomin.reload.abstractor_abstractions(true).each do |abstractor_abstraction|
        abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
          abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status_accepted
          abstractor_suggestion.save!
        end
      end
    end
  end
end

def setup_moomin_abstraction_schemas
  list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
  abstractor_abstraction_schema_moomin = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_favorite_moomin', display_name: 'Has favorite moomin', abstractor_object_type_id: list_object_type.id, preferred_name: 'Has favorite moomin').first_or_create

  ['Moomintroll', 'Little My', 'The Groke'].each do |moomin|
    abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: moomin)
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: abstractor_abstraction_schema_moomin, abstractor_object_value: abstractor_object_value)
  end

  @abstractor_subject_moomin = Abstractor::AbstractorSubject.create(subject_type: 'Moomin', abstractor_abstraction_schema: abstractor_abstraction_schema_moomin)
end