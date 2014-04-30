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
      @abstractor_subject_1 = FactoryGirl.create(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'Foo', abstractor_abstraction_schema: @abstractor_abstraction_schema_1)
      FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject_1)
      @abstractor_subject_2 = FactoryGirl.create(:abstractor_subject, abstractor_rule_type: abstractor_rule_type, subject_type: 'Foo', abstractor_abstraction_schema: @abstractor_abstraction_schema_2)
      FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject_2)
      abstractor_subject_group  = Abstractor::AbstractorSubjectGroup.create(:name => 'some group')
      Abstractor::AbstractorSubjectGroupMember.create(:abstractor_subject => @abstractor_subject_1, :abstractor_subject_group => abstractor_subject_group, :display_order => 1)
    end

    it "knows if it is a member of abstractor subject group" do
      abstractor_subject = Abstractor::AbstractorSubject.find(@abstractor_subject_1)
      abstractor_subject.groupable?.should be_true
    end

    it "knows if it is not a member of abstractor subject group" do
      subject = Abstractor::AbstractorSubject.find(@abstractor_subject_2)
      subject.groupable?.should be_false
    end
  end
end