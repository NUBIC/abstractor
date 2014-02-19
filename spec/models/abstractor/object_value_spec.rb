require 'spec_helper'

describe  Abstractor::ObjectValue do
  before(:all) do
    Abstractor::Setup.system
  end

  it "can report its object variants" do
    object_type_list = Abstractor::ObjectType.where(value: 'list').first
    abstraction_schema = FactoryGirl.create(:abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', object_type: object_type_list, preferred_name: 'property')
    abstraction_schema.object_values << FactoryGirl.build(:object_value, value: 'foo')
    FactoryGirl.create(:object_value_variant, object_value: abstraction_schema.object_values.first, value: 'boo')

    Set.new(abstraction_schema.object_values.first.object_variants).should == Set.new(['foo', 'boo'])
  end
end
