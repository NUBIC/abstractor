 require 'spec_helper'
 describe  Abstractor::AbstractorAbstraction do
   before(:all) do
     Abstractor::Setup.system
   end

   it "can detect a suggestion from a suggested value" do
     abstractor_object_type = Abstractor::AbstractorObjectType.first
     abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
     abstractor_rule_type = Abstractor::AbstractorRuleType.first
     abstractor_abstraction_schema.abstractor_subjects << FactoryGirl.build(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'Foo')
     abstractor_abstraction = FactoryGirl.create(:abstractor_abstraction, abstractor_subject: abstractor_abstraction_schema.abstractor_subjects.first, about_id: 1, unknown: true)
     abstractor_suggestion_status =  Abstractor::AbstractorSuggestionStatus.first
     abstractor_suggestion_bar = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: abstractor_abstraction, abstractor_suggestion_status: abstractor_suggestion_status, suggested_value: 'bar')
     abstractor_suggestion_boo = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: abstractor_abstraction, abstractor_suggestion_status: abstractor_suggestion_status, suggested_value: 'boo')

     abstractor_abstraction.detect_abstractor_suggestion('bar').should == abstractor_suggestion_bar
   end
 end
