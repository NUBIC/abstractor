FactoryGirl.define do
  factory :encounter_note do
    note_text ''
  end

  factory :radiation_therapy_prescription do
    site_name 'left lung'
  end

  factory :abstractor_subject, :class => Abstractor::AbstractorSubject do
  end

  factory :abstractor_abstraction_schema, class: Abstractor::AbstractorAbstractionSchema do
  end

  factory :abstractor_abstraction_schema_predicate_variant, class: Abstractor::AbstractorAbstractionSchemaPredicateVariant do
  end

  factory :abstractor_abstraction_source, class: Abstractor::AbstractorAbstractionSource do
  end

  factory :abstractor_object_value, class: Abstractor::AbstractorObjectValue do
  end

  factory :abstractor_object_value_variant, class: Abstractor::AbstractorObjectValueVariant do
  end

  factory :abstractor_abstraction, class: Abstractor::AbstractorAbstraction do
  end

  factory :abstractor_suggestion, class: Abstractor::AbstractorSuggestion do
  end

  factory :abstractor_suggestion_source, class: Abstractor::AbstractorSuggestionSource do
  end
end