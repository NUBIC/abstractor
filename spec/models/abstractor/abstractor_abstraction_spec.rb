 require 'spec_helper'
 describe  Abstractor::AbstractorAbstraction do
   before(:each) do
     Abstractor::Setup.system
     abstractor_object_type = Abstractor::AbstractorObjectType.first
     abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
     abstractor_rule_type = Abstractor::AbstractorRuleType.first
     @abstractor_subject = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
     abstractor_abstraction_schema.abstractor_subjects << @abstractor_subject
     @abstractor_abstraction = FactoryGirl.create(:abstractor_abstraction, abstractor_subject: abstractor_abstraction_schema.abstractor_subjects.first, about_id: 1, unknown: true)
     @abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(name: Abstractor::Enum::ABSTRACTOR_SUGGESTION_STATUS_NEEDS_REVIEW).first
     @abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(name: Abstractor::Enum::ABSTRACTOR_SUGGESTION_STATUS_ACCEPTED).first
     @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(name: Abstractor::Enum::ABSTRACTOR_SUGGESTION_STATUS_REJECTED).first
     @abstractor_suggestion_bar = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: @abstractor_abstraction, abstractor_suggestion_status: @abstractor_suggestion_status_needs_review, suggested_value: 'bar')
     @abstractor_suggestion_boo = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: @abstractor_abstraction, abstractor_suggestion_status: @abstractor_suggestion_status_needs_review, suggested_value: 'boo')
     @abstractor_suggestion_foo = FactoryGirl.create(:abstractor_suggestion, abstractor_abstraction: @abstractor_abstraction, abstractor_suggestion_status: @abstractor_suggestion_status_rejected, suggested_value: 'foo')
     @abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject)
   end

   it "can detect a suggestion from a suggested value", focus: false do
     expect(@abstractor_abstraction.detect_abstractor_suggestion('bar', nil, nil)).to eq(@abstractor_suggestion_bar)
   end

   it "knows if an abstraction is unreviewed", focus: false do
     expect(@abstractor_abstraction.unreviewed?).to be_truthy
   end

   it "can report unreviewd suggestions", focus: false do
     expect(@abstractor_abstraction.unreviewed_abstractor_suggestions).to eq([@abstractor_suggestion_bar, @abstractor_suggestion_boo])
   end

   it 'can remove unreviewed suggestions not matching suggestions', focus: false do
     @abstractor_abstraction.remove_unreviewed_suggestions_not_matching_suggestions([{suggestion: 'bar', explanation: 'Here is the deal.' }])
     expect(@abstractor_abstraction.reload.abstractor_suggestions).to eq([@abstractor_suggestion_bar, @abstractor_suggestion_foo])
   end

   it "knows if an abstraction is not unreviewed", focus: false do
     @abstractor_suggestion_bar.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
     @abstractor_suggestion_bar.save

     expect(@abstractor_abstraction.reload.unreviewed?).to be_falsey
   end

   it "can detect an indirect source", focus: false do
     @abstractor_abstraction.abstractor_indirect_sources.build(abstractor_abstraction_source: @abstractor_abstraction_source)
     @abstractor_abstraction.save!
     expect(@abstractor_abstraction.reload.detect_abstractor_indirect_source(@abstractor_abstraction_source)).to_not be_nil
   end
 end
