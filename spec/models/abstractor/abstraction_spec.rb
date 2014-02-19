 require 'spec_helper'

 describe  Abstractor::Abstraction do
   before(:all) do
     Abstractor::Setup.system
   end

   it "can detect a suggestion from a suggested value" do
     object_type = Abstractor::ObjectType.first
     abstraction_schema = FactoryGirl.create(:abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', object_type: object_type, preferred_name: 'property')
     rule_type = Abstractor::RuleType.first
     abstraction_schema.abstractor_subjects << FactoryGirl.build(:abstractor_subject, rule_type: rule_type, subject_type: 'Foo')
     abstraction = FactoryGirl.create(:abstraction, abstractor_subject: abstraction_schema.abstractor_subjects.first, subject_id: 1, unknown: true)
     suggestion_status =  Abstractor::SuggestionStatus.first
     suggestion_bar = FactoryGirl.create(:suggestion, abstraction: abstraction, suggestion_status: suggestion_status, suggested_value: 'bar')
     suggestion_boo = FactoryGirl.create(:suggestion, abstraction: abstraction, suggestion_status: suggestion_status, suggested_value: 'boo')

     abstraction.detect_suggestion('bar').should == suggestion_bar
   end
 end
