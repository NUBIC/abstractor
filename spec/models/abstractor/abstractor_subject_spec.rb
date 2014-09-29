require 'spec_helper'
describe  Abstractor::AbstractorSubject do
  before(:all) do
    Abstractor::Setup.system
  end
  describe "grouping" do
    before(:each) do
      abstractor_object_type = Abstractor::AbstractorObjectType.first
      @abstractor_abstraction_schema_1 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'some property')
      @abstractor_abstraction_schema_2 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_other_property', display_name: 'some_other_property', abstractor_object_type: abstractor_object_type, preferred_name: 'some other property')
      abstractor_rule_type = Abstractor::AbstractorRuleType.first
      abstractor_abstraction_source_type = Abstractor::AbstractorAbstractionSourceType.first
      @abstractor_subject_1 = FactoryGirl.create(:abstractor_subject, subject_type: 'Foo', abstractor_abstraction_schema: @abstractor_abstraction_schema_1)
      FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject_1, abstractor_rule_type: abstractor_rule_type, abstractor_abstraction_source_type: abstractor_abstraction_source_type)
      @abstractor_subject_2 = FactoryGirl.create(:abstractor_subject, subject_type: 'Foo', abstractor_abstraction_schema: @abstractor_abstraction_schema_2)
      FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject_2, abstractor_rule_type: abstractor_rule_type, abstractor_abstraction_source_type: abstractor_abstraction_source_type)
      abstractor_subject_group  = Abstractor::AbstractorSubjectGroup.create(:name => 'some group')
      Abstractor::AbstractorSubjectGroupMember.create(:abstractor_subject => @abstractor_subject_1, :abstractor_subject_group => abstractor_subject_group, :display_order => 1)
    end

    it "knows if it is a member of abstractor subject group", focus: false do
      abstractor_subject = Abstractor::AbstractorSubject.find(@abstractor_subject_1)
      expect(abstractor_subject.groupable?).to be_truthy
    end

    it "knows if it is not a member of abstractor subject group", focus: false do
      subject = Abstractor::AbstractorSubject.find(@abstractor_subject_2)
      expect(subject.groupable?).to be_falsey
    end
  end
end