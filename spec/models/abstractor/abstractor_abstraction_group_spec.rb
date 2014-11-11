require 'spec_helper'
describe Abstractor::AbstractorAbstractionGroup do
  let!(:abstractor_subject_group) { FactoryGirl.create(:abstractor_subject_group) }

  before(:each) do
    @abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_falls', display_name: 'Falls')
    @subject_group = abstractor_subject_group

    @abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: @abstractor_subject, abstractor_subject_group: @subject_group, display_order: 1)
    @abstraction = @abstractor_subject.abstractor_abstractions.build(about_id: 1, about_type: ImagingExam.to_s)
    @abstraction.save!

    @imaging_exam = FactoryGirl.create(:imaging_exam)
  end

  it "is not valid if AbstractorSubjectGroup does not have members" do
    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: abstractor_subject_group.id)
    expect(abstractor_abstraction_group).not_to be_valid
    expect(abstractor_abstraction_group.errors.full_messages).to include 'Must have at least one abstractor_abstraction_group_member'
  end

  # it "is not valid if members belong to different namespaces" do
  #   abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: ImagingExam.to_s, about_id: 1)
  #   abstractor_abstraction_group.abstractor_abstractions << @abstraction
  #   expect(abstractor_abstraction_group).to be_valid

  #   abstractor_subject_1 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
  #   Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_1, abstractor_subject_group: @subject_group, display_order: 1)
  #   abstraction_1 = abstractor_subject_1.abstractor_abstractions.build(about_id: 1, about_type: ImagingExam.to_s)
  #   abstraction_1.save!

  #   abstractor_abstraction_group.abstractor_abstractions << abstraction_1
  #   expect(abstractor_abstraction_group).not_to be_valid
  #   expect(abstractor_abstraction_group.errors.full_messages).to include 'Must have same namespace for all abstractor_abstraction_group_members'
  # end

  # it "is valid if members belong to the same namespace" do
  #   abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: ImagingExam.to_s, about_id: 1)
  #   abstractor_abstraction_group.abstractor_abstractions << @abstraction
  #   expect(abstractor_abstraction_group).to be_valid

  #   abstractor_subject_1 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
  #   Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_1, abstractor_subject_group: @subject_group, display_order: 1)
  #   abstraction_1 = abstractor_subject_1.abstractor_abstractions.build(about_id: 1, about_type: ImagingExam.to_s)
  #   abstraction_1.save!

  #   abstractor_abstraction_group.abstractor_abstractions << @abstraction
  #   expect(abstractor_abstraction_group).to be_valid
  # end

  it "is is valid if parent AbstractorSubjectGroup cardinality is not defined" do
    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    expect(abstractor_abstraction_group).to be_valid
    abstractor_abstraction_group.save!

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    expect(abstractor_abstraction_group).to be_valid
  end

  it "is is valid if maximum number of groups for parent AbstractorSubjectGroup is not reached" do
    @subject_group.cardinality = 1
    @subject_group.save

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    expect(abstractor_abstraction_group).to be_valid
  end

  it "is is not valid if maximum number of groups for parent AbstractorSubjectGroup is reached" do
    @subject_group.cardinality = 1
    @subject_group.save

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    abstractor_abstraction_group.save!

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    expect(abstractor_abstraction_group).not_to be_valid
    expect(abstractor_abstraction_group.errors.full_messages).to include 'Subject group reached maximum number of abstraction groups (1)'
  end

  it "is does not count deleted abstraction_groups" do
    @subject_group.cardinality = 1
    @subject_group.save

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    abstractor_abstraction_group.save!
    abstractor_abstraction_group.soft_delete!

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << @abstraction
    expect(abstractor_abstraction_group).to be_valid
  end

  # it "if cardinality is defined and grouped abstractions are namespaced, it checks cardinality against each namespace" do
  #   @subject_group.cardinality = 1
  #   @subject_group.save

  #   abstractor_subject_1 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
  #   Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_1, abstractor_subject_group: @subject_group, display_order: 1)
  #   abstraction_1 = abstractor_subject_1.abstractor_abstractions.build(about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
  #   abstraction_1.save!

  #   abstractor_subject_2 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
  #   Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_2, abstractor_subject_group: @subject_group, display_order: 1)
  #   abstraction_2 = abstractor_subject_2.abstractor_abstractions.build(about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
  #   abstraction_2.save!

  #   @subject_group.reload.abstractor_subjects.each do |abstractor_subject|
  #     abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
  #     abstractor_abstraction_group.abstractor_abstractions << abstractor_subject.abstractor_abstractions.first
  #     expect(abstractor_abstraction_group).to be_valid
  #     abstractor_abstraction_group.save!

  #     abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
  #     abstractor_abstraction_group.abstractor_abstractions << abstractor_subject.abstractor_abstractions.first
  #     expect(abstractor_abstraction_group).not_to be_valid
  #   end
  # end

  it "if cardinality is defined and grouped abstractions are namespaced, it checks cardinality against each about" do
    @subject_group.cardinality = 1
    @subject_group.save

    abstractor_subject_1 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_1, abstractor_subject_group: @subject_group, display_order: 1)
    abstraction_1 = abstractor_subject_1.abstractor_abstractions.build(about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstraction_1.save!

    abstractor_subject_2 = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: @abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject_2, abstractor_subject_group: @subject_group, display_order: 1)
    abstraction_2 = abstractor_subject_2.abstractor_abstractions.build(about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstraction_2.save!

    imaging_exam_2 = FactoryGirl.create(:imaging_exam)

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << abstractor_subject_1.abstractor_abstractions.first
    expect(abstractor_abstraction_group).to be_valid
    abstractor_abstraction_group.save!

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: @imaging_exam.class.to_s, about_id: @imaging_exam.id)
    abstractor_abstraction_group.abstractor_abstractions << abstractor_subject_1.abstractor_abstractions.first
    expect(abstractor_abstraction_group).not_to be_valid

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: imaging_exam_2.class.to_s, about_id: imaging_exam_2.id)
    abstractor_abstraction_group.abstractor_abstractions << abstractor_subject_2.abstractor_abstractions.first
    expect(abstractor_abstraction_group).to be_valid
    abstractor_abstraction_group.save!

    abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.new(abstractor_subject_group_id: @subject_group.id, about_type: imaging_exam_2.class.to_s, about_id: imaging_exam_2.id)
    abstractor_abstraction_group.abstractor_abstractions << abstractor_subject_2.abstractor_abstractions.first
    expect(abstractor_abstraction_group).not_to be_valid
  end
end