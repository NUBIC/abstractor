require 'spec_helper'
describe  Abstractor::AbstractorSuggestion do
  before(:all) do
    Abstractor::Setup.system
  end

  it "can detect a suggestion from a suggested value" do
    abstractor_object_type = Abstractor::AbstractorObjectType.first
    abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
    abstractor_rule_type = Abstractor::AbstractorRuleType.first
    abstractor_abstraction_schema.abstractor_subjects << FactoryGirl.build(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'Foo')
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: abstractor_abstraction_schema.abstractor_subjects.first)
    abstractor_abstraction = FactoryGirl.create(:abstractor_abstraction, abstractor_subject: abstractor_abstraction_schema.abstractor_subjects.first, about_id: 1, unknown: true)
    abstractor_suggestion_status =  Abstractor::AbstractorSuggestionStatus.first
    abstractor_suggestion_bar = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: abstractor_abstraction, abstractor_suggestion_status: abstractor_suggestion_status, suggested_value: 'bar')
    abstractor_suggestion_boo = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: abstractor_abstraction, abstractor_suggestion_status: abstractor_suggestion_status, suggested_value: 'boo')
    abstractor_suggestion_source_bar = FactoryGirl.create(:abstractor_suggestion_source, abstractor_suggestion: abstractor_suggestion_bar, abstractor_abstraction_source: abstractor_abstraction_source, match_value: 'bar', sentence_match_value: 'bar', source_id: 1, source_type: 'Foo')
    suggestion_source_bar_like = FactoryGirl.create(:abstractor_suggestion_source, abstractor_suggestion: abstractor_suggestion_bar, abstractor_abstraction_source: abstractor_abstraction_source, match_value: 'bar-like', source_id: 1, source_type: 'Foo')

    abstractor_suggestion_bar.detect_abstractor_suggestion_source(abstractor_abstraction_source, 'bar', 1, 'Foo').should == abstractor_suggestion_source_bar
  end
end
