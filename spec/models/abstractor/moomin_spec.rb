require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Moomin do
  before(:all) do
    Abstractor::Setup.system
    n_v_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    value_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first

    subject_group  = Abstractor::AbstractorSubjectGroup.where(name: 'Family history of movement disorder: aunts and uncles').first_or_create

    @abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_relative_with_movement_disorder_aunt_or_uncle',
      display_name: 'Disorder',
      abstractor_object_type: list_object_type,
      preferred_name: 'disorder').first_or_create

    abstractor_abstraction_schema_predicate_variant?(@abstractor_abstraction_schema, 'aunts')
    abstractor_abstraction_schema_predicate_variant?(@abstractor_abstraction_schema, 'aunt')
    abstractor_abstraction_schema_predicate_variant?(@abstractor_abstraction_schema, 'uncles')
    abstractor_abstraction_schema_predicate_variant?(@abstractor_abstraction_schema, 'uncle')

    set_diagnosis_values_for_schema(@abstractor_abstraction_schema)

    @abstractor_subject = Abstractor::AbstractorSubject.where(
      subject_type: 'Moomin',
      abstractor_abstraction_schema: @abstractor_abstraction_schema,
      namespace_type: "Discener::Seearch",
      namespace_id: 1).first_or_create

    Abstractor::AbstractorSubjectGroupMember.where(
      abstractor_subject: @abstractor_subject,
      abstractor_subject_group: subject_group,
      display_order: 1).first_or_create

    Abstractor::AbstractorAbstractionSource.where(
      abstractor_subject: @abstractor_subject,
      from_method: 'note_text',
      abstractor_rule_type: n_v_rule,
      abstractor_abstraction_source_type: source_type_nlp_suggestion).first_or_create
  end

  it "works", focus: true do
    note_text=<<EOS
  Lives alone.
  Mother - age 88, stroke; no tremors
  Father - died age 75, kidney disease; no tremors
  Paternal aunt and uncle both had PD
  2 sisters, 1 brother - htn; no tremors.
  2 daughters - healthy
  No other neurologic problems in the family.
  b0
EOS

    moomin = FactoryGirl.create(:moomin, note_text: note_text)
    moomin.abstract
    expect(moomin.reload.detect_abstractor_abstraction(@abstractor_subject).abstractor_suggestions.first.suggested_value).to be_nil
    # expect(moomin.reload.detect_abstractor_abstraction(@abstractor_subject).abstractor_suggestions.size).to eq(0)
  end
end

def abstractor_abstraction_schema_predicate_variant?(abstractor_abstraction_schema, value)
  if abstractor_abstraction_schema.abstractor_abstraction_schema_predicate_variants.select { |abstractor_abstraction_schema_predicate_variant| abstractor_abstraction_schema_predicate_variant.value == value }.empty?
    abstractor_abstraction_schema.abstractor_abstraction_schema_predicate_variants.build(value: value)
  end
end

def set_diagnosis_values_for_schema(abstraction_schema)
  pd_diagnoses = YAML.load(ERB.new(File.read("#{Rails.root}/lib/setup/data/simuni_diagnoses.yml")).result)
  pd_diagnoses.each do |diagnosis_hash|
    abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: diagnosis_hash[:diagnosis]).first_or_create
    if diagnosis_hash[:umls_synonyms]
      diagnosis_hash[:umls_synonyms].each do |synonym|
        Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: synonym).first_or_create
      end
    end
    if diagnosis_hash[:custom_synonyms]
      diagnosis_hash[:custom_synonyms].each do |synonym|
        Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: synonym).first_or_create
      end
    end
    create_abstraction_schema_object_value(abstraction_schema, abstractor_object_value)
  end
end

def create_abstraction_schema_object_value(abstraction_schema, abstractor_object_value)
  Abstractor::AbstractorAbstractionSchemaObjectValue.where(
    abstractor_abstraction_schema: abstraction_schema,
    abstractor_object_value: abstractor_object_value).first_or_create
end