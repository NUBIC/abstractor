require 'spec_helper'
describe Abstractor::AbstractorAbstractionSchema do
  before(:all) do
    Abstractor::Setup.system
  end

  it "can report its predicate variants (including its preferred name)", focus: false do
    abstractor_object_type = Abstractor::AbstractorObjectType.first
    abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
    abstractor_abstraction_schema.abstractor_abstraction_schema_predicate_variants << FactoryGirl.build(:abstractor_abstraction_schema_predicate_variant, value: 'smoperty')
    expect(Set.new(abstractor_abstraction_schema.predicate_variants)).to eq(Set.new(['property', 'smoperty']))
  end
end
