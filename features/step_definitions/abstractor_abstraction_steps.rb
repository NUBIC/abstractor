Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? equal highlighted text "([^\"]*)"$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    elements_selector = "#{selector} strong.highlight"
    match = false
    all(elements_selector, :visible => true).each do |e|
      match = true if e.text == value
    end
    if negation.blank?
      match.should be_truthy
    else
      match.should be_falsey
    end
  }
end

def set_abstractor_suggestion_for_object(object, status, applicable_case=nil, value=nil, match_values=[])
  abstractor_abstraction = object.abstractor_abstractions.last
  source = abstractor_abstraction.abstractor_subject.abstractor_abstraction_sources.first

  unknown         = applicable_case == 'unknown' ? true : false
  not_applicable  = applicable_case == 'not applicable' ? true : false
  suggested_value = abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.abstractor_object_values.where(:value => value).first.value if value

  suggestion = Abstractor::AbstractorSuggestion.create!(abstractor_abstraction: abstractor_abstraction, unknown: unknown, not_applicable: not_applicable, suggested_value: suggested_value)

  needs_review_status = Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first
  accepted_status     = Abstractor::AbstractorSuggestionStatus.where(name: 'Accepted').first
  rejected_status     = Abstractor::AbstractorSuggestionStatus.where(name: 'Rejected').first

  case status
  when 'accepted'
    suggestion.abstractor_suggestion_status = accepted_status
  when 'rejected'
    suggestion.abstractor_suggestion_status = rejected_status
  else
    suggestion.abstractor_suggestion_status = needs_review_status
  end

  suggestion.save!

  match_values ||= [suggested_value]
  match_values.split(', ').each do |value|
    Abstractor::AbstractorSuggestionSource.create!(:abstractor_suggestion => suggestion, :abstractor_abstraction_source => source, :match_value => value, source_id: abstractor_abstraction.subject_id, source_type: abstractor_abstraction.abstractor_subject.subject_type, source_method: source.from_method )
  end
end