require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Surgery do
  before(:each) do
    Abstractor::Setup.system
    Setup.surgery
    @abstractor_abstraction_schema_imaging_confirmed_extent_of_resection = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_imaging_confirmed_extent_of_resection').first
    @abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection = Abstractor::AbstractorSubject.where(subject_type: Surgery.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_imaging_confirmed_extent_of_resection.id).first
    indirect_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'indirect').first
    @abstractor_abstraction_source_indirect_imaging_exam = @abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection.abstractor_abstraction_sources.find { |aas| aas.abstractor_abstraction_source_type == indirect_source_type  &&  aas.from_method == 'patient_imaging_exams' }
    @abstractor_abstraction_source_indirect_sugical_procedure_report = @abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection.abstractor_abstraction_sources.find { |aas| aas.abstractor_abstraction_source_type == indirect_source_type  &&  aas.from_method == 'patient_surgical_procedure_reports' }
  end

  before(:each) do
    @surgery = FactoryGirl.create(:surgery)

  end

  it "creates a 'has_imaging_confirmed_extent_of_resection' abstraction for an abstractor abstracton source type 'indirect'", focus: false do
    @surgery.abstract
    expect(@surgery.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection)).to_not be_nil
  end

  it "creates an abstractor indirect source for each abstractor abstracton source type 'indirect' setup", focus: false do
    @surgery.abstract
    expect(@surgery.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection).abstractor_indirect_sources.size).to eq(2)
  end

  it "does not recreate an abstractor indirect source for an abstractor abstracton source type 'indirect' upon re-abstraction", focus: false do
    @surgery.abstract
    expect(@surgery.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection).abstractor_indirect_sources.size).to eq(2)
    @surgery.abstract
    expect(@surgery.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection).abstractor_indirect_sources.size).to eq(2)
  end

  it "defaults an abstractor indirect source to an initial state upon abstraction", focus: false do
    @surgery.abstract
    abstractor_abstraction = @surgery.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_imaging_confirmed_extent_of_resection)
    abstractor_indirect_source = abstractor_abstraction.detect_abstractor_indirect_source(@abstractor_abstraction_source_indirect_imaging_exam)
    default = { source_type: ImagingExam.to_s, source_id: nil, sourece_method: 'note_text' }

    expect({ source_type: abstractor_indirect_source.source_type, source_id: abstractor_indirect_source.source_id, sourece_method: abstractor_indirect_source.source_method }).to eq(default)
  end

  it "can remove abstractions (with indirect sources)", focus: false do
    expect(Abstractor::AbstractorIndirectSource.count).to eq(0)
    @surgery.abstract
    expect(@surgery.reload.abstractor_abstractions.map { |abstractor_abstraction| abstractor_abstraction.abstractor_indirect_sources }.flatten.compact.size).to eq(2)
    @surgery.remove_abstractions
    expect(Abstractor::AbstractorIndirectSource.count).to eq(0)
  end

  describe "updating all abstraction group members (including abstractions without suggestions)" do
    before(:each) do
      @surgery.abstract
      @abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Surgery Anatomical Location').first
      @abstractor_abstraction_group = @surgery.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.first
    end

    it "to 'not applicable'", focus: false do
      expect(@abstractor_abstraction_group.abstractor_abstractions.map(&:not_applicable)).to eq([nil, nil])
      Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE)
      expect(@abstractor_abstraction_group.reload.abstractor_abstractions.map(&:not_applicable)).to eq([true, true])
    end

    it "to 'unknown'", focus: false do
      expect(@abstractor_abstraction_group.abstractor_abstractions.map(&:unknown)).to eq([nil, nil])
      Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN)
      expect(@abstractor_abstraction_group.reload.abstractor_abstractions.map(&:unknown)).to eq([true, true])
    end
  end
end