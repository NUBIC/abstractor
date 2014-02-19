FactoryGirl.define do
  factory :abstractor_subject, :class => Abstractor::Subject do
  end

  factory :encounter_note do
    note_text ''
  end

  factory :radiation_therapy_prescription do
    site_name 'left lung'
  end

  factory :abstraction_schema, class: Abstractor::AbstractionSchema do
  end

  factory :abstraction_schema_predicate_variant, class: Abstractor::AbstractionSchemaPredicateVariant do
  end

  factory :abstraction_source, class: Abstractor::AbstractionSource do
  end

  factory :object_value, class: Abstractor::ObjectValue do
  end

  factory :object_value_variant, class: Abstractor::ObjectValueVariant do
  end

  factory :abstraction, class: Abstractor::Abstraction do
  end

  factory :suggestion, class: Abstractor::Suggestion do
  end

  factory :suggestion_source, class: Abstractor::SuggestionSource do
  end
end