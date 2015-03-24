FactoryGirl.define do
  factory :article do
    note_text  ''
  end

  factory :moomin do
    note_text  ''
  end

  factory :surgical_procedure do
    sequence(:surg_case_id)
    description ''
    modifier    ''
  end

  factory :surgical_procedure_report do
    note_text ''
    sequence(:patient_id)
  end

  factory :imaging_exam do
    report_date Date.today
    note_text ''
    sequence(:patient_id)
    sequence(:accession_number) do |n|
      "#{n}"
    end
  end

  factory :surgery do
    sequence(:surg_case_id)
    sequence(:surg_case_nbr) do |n|
      "OR-#{n}"
    end
    sequence(:patient_id)
  end

  factory :pathology_case do
    note_text ''
  end

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

  factory :abstractor_subject_group, :class => Abstractor::AbstractorSubjectGroup do
    cardinality nil
  end
end