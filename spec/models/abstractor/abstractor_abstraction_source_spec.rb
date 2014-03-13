require 'spec_helper'
describe  Abstractor::AbstractorAbstractionSource do
  before(:each) do
    Abstractor::Setup.system
    abstractor_object_type = Abstractor::AbstractorObjectType.first
    @abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'some property')
    abstractor_rule_type = Abstractor::AbstractorRuleType.first
    @abstractor_subject = FactoryGirl.create(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'EncounterNote', abstractor_abstraction_schema: @abstractor_abstraction_schema)
    @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'Little my says hi!')
  end

  it "can normalize its from method from a string" do
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'note_text')
    abstractor_abstraction_source.normalize_from_method_to_sources(@encounter_note).should == [{:source_type=>EncounterNote, :source_id=> @encounter_note.id, :source_method=>"note_text"}]
  end

  it "can normalize its from method from a nil" do
    encounter_note = FactoryGirl.create(:encounter_note, note_text: "can't be nil")
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'custom_method_nil')
    abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).should == [{:source_type=>EncounterNote, :source_id=> encounter_note.id, :source_method=>"custom_method_nil"}]
  end

  it "can normalize its from method from a custom method" do
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'custom_method')
    abstractor_abstraction_source.normalize_from_method_to_sources(@encounter_note).should == [{:source_type=> nil, :source_id=> nil, :source_method=>nil}]
  end
end