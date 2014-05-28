 require 'spec_helper'
 describe  Abstractor::AbstractorAbstraction do
   before(:all) do
     Abstractor::Setup.system
     abstractor_object_type = Abstractor::AbstractorObjectType.first
     abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
     abstractor_rule_type = Abstractor::AbstractorRuleType.first
     abstractor_abstraction_schema.abstractor_subjects << FactoryGirl.build(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'Foo')
     @abstractor_abstraction = FactoryGirl.create(:abstractor_abstraction, abstractor_subject: abstractor_abstraction_schema.abstractor_subjects.first, about_id: 1, unknown: true)
     @abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first
     @abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
     @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
     @abstractor_suggestion_bar = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: @abstractor_abstraction, abstractor_suggestion_status: @abstractor_suggestion_status_needs_review, suggested_value: 'bar')
     @abstractor_suggestion_boo = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: @abstractor_abstraction, abstractor_suggestion_status: @abstractor_suggestion_status_needs_review, suggested_value: 'boo')
   end

   it "can detect a suggestion from a suggested value", focus: false do
     @abstractor_abstraction.detect_abstractor_suggestion('bar').should == @abstractor_suggestion_bar
   end

   it "knows if an abstraction is unreviewed", focus: false do
     expect(@abstractor_abstraction.unreviewed?).to be_true
   end

   it "knows if an abstraction is not unreviewed", focus: false do
     @abstractor_suggestion_bar.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
     @abstractor_suggestion_bar.save

     expect(@abstractor_abstraction.reload.unreviewed?).to be_false
   end
 end
