require 'spec_helper'
describe Abstractor::AbstractorSubjectGroup do
  let!(:abstractor_subject_group) { FactoryGirl.create(:abstractor_subject_group) }

  it "is valid with valid attributes" do
    expect(abstractor_subject_group).to be_valid
    r = Abstractor::AbstractorSubjectGroup.new(cardinality: 5)
    expect(r).to be_valid
  end

  it "validates that abstractor_subject_group cardinality is a number" do
    r = Abstractor::AbstractorSubjectGroup.new(cardinality: 'a')
    expect(r).to_not be_valid
    expect(r.errors.full_messages).to include 'Cardinality is not a number'
  end

  it "validates that abstractor_subject_group cardinality is greater than 0" do
    r = Abstractor::AbstractorSubjectGroup.new(cardinality: -1)
    expect(r).to_not be_valid
    expect(r.errors.full_messages).to include 'Cardinality must be greater than 0'

    r = Abstractor::AbstractorSubjectGroup.new(cardinality: 0)
    expect(r).to_not be_valid
    expect(r.errors.full_messages).to include 'Cardinality must be greater than 0'
  end
end
