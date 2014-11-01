require 'spec_helper'
describe Abstractor::AbstractorAbstractionGroup do
  let!(:abstractor_subject_group) { FactoryGirl.create(:abstractor_subject_group) }

  it "is is valid if parent AbstractorSubjectGroup cardinality is not defined" do
    r = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id)
    expect(r).to be_valid
  end

  it "is is valid if maximum number of groups for parent AbstractorSubjectGroup is not reached" do
    abstractor_subject_group.cardinality = 1
    abstractor_subject_group.save

    r = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id)
    expect(r).to be_valid
    r.save!
  end

  it "is is not valid if maximum number of groups for parent AbstractorSubjectGroup is reached" do
    abstractor_subject_group.cardinality = 1
    abstractor_subject_group.save

    Abstractor::AbstractorAbstractionGroup.create(abstractor_subject_group_id: abstractor_subject_group.id)
    r = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id)
    expect(r).not_to be_valid
    expect(r.errors.full_messages).to include 'Subject group reached maximum number of abstraction groups (1)'
  end

  it "is does not count deleted abstraction_groups" do
    abstractor_subject_group.cardinality = 1
    abstractor_subject_group.save

    r1 = Abstractor::AbstractorAbstractionGroup.create(abstractor_subject_group_id: abstractor_subject_group.id)
    r1.soft_delete!

    r = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id)
    expect(r).to be_valid
    r.save!
  end
end
