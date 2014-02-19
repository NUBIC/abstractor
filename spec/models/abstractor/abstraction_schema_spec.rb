require 'spec_helper'

describe Abstractor::AbstractionSchema do
  before(:all) do
    Abstractor::Setup.system
  end

  it "can report its predicate variants (including its preferred name)" do
    object_type = Abstractor::ObjectType.first
    abstraction_schema = FactoryGirl.create(:abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', object_type: object_type, preferred_name: 'property')
    abstraction_schema.abstraction_schema_predicate_variants << FactoryGirl.build(:abstraction_schema_predicate_variant, value: 'smoperty')
    Set.new(abstraction_schema.predicate_variants).should == Set.new(['property', 'smoperty'])
  end
end
