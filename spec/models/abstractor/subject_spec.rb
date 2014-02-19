require 'spec_helper'
describe  Abstractor::Subject do
  before(:all) do
    Abstractor::Setup.system
  end
  describe "grouping" do
    before(:each) do
      object_type = Abstractor::ObjectType.first
      @abstraction_schema_1 = FactoryGirl.create(:abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', object_type: object_type, preferred_name: 'some property')
      @abstraction_schema_2 = FactoryGirl.create(:abstraction_schema, predicate: 'has_some_other_property', display_name: 'some_other_property', object_type: object_type, preferred_name: 'some other property')
      rule_type = Abstractor::RuleType.first
      @abstractor_subject_1 = FactoryGirl.create(:abstractor_subject, rule_type: rule_type, subject_type: 'Foo', abstraction_schema: @abstraction_schema_1)
      FactoryGirl.create(:abstraction_source, abstractor_subject: @abstractor_subject_1)
      @abstractor_subject_2 = FactoryGirl.create(:abstractor_subject, rule_type: rule_type, subject_type: 'Foo', abstraction_schema: @abstraction_schema_2)
      FactoryGirl.create(:abstraction_source, abstractor_subject: @abstractor_subject_2)
      subject_group  = Abstractor::SubjectGroup.create(:name => 'some group')
      Abstractor::SubjectGroupMember.create(:abstractor_subject => @abstractor_subject_1, :subject_group => subject_group, :display_order => 1)
    end

    it "knows if it is a member of abstractor subject group" do
      abstractor_subject = Abstractor::Subject.find(@abstractor_subject_1)
      abstractor_subject.groupable?.should be_true
    end

    it "knows if it is not a member of abstractor subject group" do
      subject = Abstractor::Subject.find(@abstractor_subject_2)
      subject.groupable?.should be_false
    end
  end
end