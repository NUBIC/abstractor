require 'spec_helper'
describe  Abstractor::AbstractorObjectValue do
  before(:all) do
    Abstractor::Setup.system
  end

  it "can report its object variants" do
    abstractor_object_type_list = Abstractor::AbstractorObjectType.where(value: 'list').first
    abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type_list, preferred_name: 'property')
    abstractor_abstraction_schema.abstractor_object_values << FactoryGirl.build(:abstractor_object_value, value: 'foo')
    FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: abstractor_abstraction_schema.abstractor_object_values.first, value: 'boo')

    expect(Set.new(abstractor_abstraction_schema.abstractor_object_values.first.object_variants)).to eq(Set.new(['foo', 'boo']))
  end
end
