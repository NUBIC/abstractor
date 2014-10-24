require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe ImagingExam do
  before(:all) do
    Setup.sites
    Setup.custom_site_synonyms
    Setup.site_categories
    Setup.laterality
    Abstractor::Setup.system
    Setup.imaging_exam
    @abstractor_abstraction_schema_moomin_major = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_favorite_major_moomin_character').first
    @abstractor_subject_abstraction_schema_moomin_major = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_moomin_major.id, namespace_type: 'Discerner::Search', namespace_id: 1).first
    @abstractor_abstraction_schema_moomin_minor = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_favorite_minor_moomin_character').first
    @abstractor_subject_abstraction_schema_moomin_minor = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_moomin_minor.id, namespace_type: 'Discerner::Search', namespace_id: 1).first
    @abstractor_abstraction_schema_dat = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_dopamine_transporter_level').first
    @abstractor_subject_abstraction_schema_dat = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_dat.id, namespace_type: 'Discerner::Search', namespace_id: 1).first
    @abstractor_abstraction_schema_anatomical_location = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_anatomical_location').first
    @abstractor_subject_abstraction_schema_dat_anatomical_location = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_anatomical_location.id, namespace_type: 'Discerner::Search', namespace_id: 1).first
    @abstractor_abstraction_schema_recist_response = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_recist_response_criteria').first
    @abstractor_subject_abstraction_schema_recist_response = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_recist_response.id, namespace_type: 'Discerner::Search', namespace_id: 2).first
    @abstractor_subject_abstraction_schema_recist_anatomical_location = Abstractor::AbstractorSubject.where(subject_type: ImagingExam.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_recist_response.id, namespace_type: 'Discerner::Search', namespace_id: 2).first
    @abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
    @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
  end

  before(:each) do
    @imaging_exam = FactoryGirl.create(:imaging_exam)
  end

  it "can report its abstractor subjects (namespaced)", focus: false do
    expect(Set.new(ImagingExam.abstractor_subjects(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id ))).to eq(Set.new([@abstractor_subject_abstraction_schema_dat, @abstractor_subject_abstraction_schema_dat_anatomical_location, @abstractor_subject_abstraction_schema_moomin_major]))
  end

  it "can report its abstractor abstraction schemas (namespaced)", focus: false do
    expect(Set.new(ImagingExam.abstractor_abstraction_schemas(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id))).to eq(Set.new([@abstractor_abstraction_schema_dat, @abstractor_abstraction_schema_anatomical_location,@abstractor_abstraction_schema_moomin_major]))
  end

  describe "abstracting (namespaced)" do
    before(:each) do
      @abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'RECIST response criteria').first
      @imaging_exam.note_text = 'The patient looks healthy.  Looks like a complete response to me.'
      @imaging_exam.save!
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id)
    end

    #creating abstractions
    it "creates abstractions in the namespace", focus: false do
      expect(@imaging_exam.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_recist_response)).to_not be_nil
    end

    it "does not creates abstractions outside of the namespae", focus: false do
      expect(@imaging_exam.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_dat)).to be_nil
    end

    it "does not create another namespaced abstraction upon re-abstraction", focus: false do
      @imaging_exam.reload.abstract(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_recist_response_criteria' }.size).to eq(1)
    end

    # creating groups
    it "creates a abstractor abstraction group in a namespace", focus: false do
      expect(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.size).to eq(1)
    end

    it "does not creates a abstractor abstraction group outside of a namespace", focus: false do
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Dopamine Transporter Level').first
      expect(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.size).to eq(0)
    end

    it "does not creates another abstractor abstraction group in a namespace upon re-abstraction", focus: false do
      @imaging_exam.reload.abstract
      expect(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.size).to eq(1)
    end

    it "creates an abstractor abstraction group member for each abstractor abstraction in a namespace", focus: false do
      expect(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.first.abstractor_abstractions.size).to eq(2)
    end

    it "does not create duplicate abstractor abstraction group members in a namespace upon re-abstraction", focus: false do
      @imaging_exam.reload.abstract
      expect(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.first.abstractor_abstractions.size).to eq(2)
    end

    it "creates an abstractor abstraction group member of the right kind for each abstractor abstraction in a namespace", focus: false do
      expect(Set.new(@imaging_exam.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == @abstractor_subject_group }.first.abstractor_abstractions.map(&:abstractor_abstraction_schema))).to eq(Set.new([@abstractor_abstraction_schema_recist_response, @abstractor_abstraction_schema_anatomical_location]))
    end

    #reporting namespaced abstractions
    it 'can return abstractor abstractions in a namespace', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id).size).to eq(3)
    end

    it 'can return abstractor abstractions (regardless of namespace)', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace.size).to eq(6)
    end

    #reporting namespaced grouped abstractions
    it 'can return abstractor abstraction groups in a namespace', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstraction_groups_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id).size).to eq(1)
    end

    it 'can return abstractor abstraction groups (regardless of namespace)', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstraction_groups_by_namespace.size).to eq(2)
    end

    it 'can return abstractor abstraction groups (regardless of namespace) but not excluding soft deleted rows', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      @imaging_exam.abstractor_abstraction_groups.first.soft_delete!
      expect(@imaging_exam.reload.abstractor_abstraction_groups_by_namespace.size).to eq(1)
    end


    it 'can return abstractor abstraction groups (regardless of namespace) but not excluding soft deleted rows', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      @imaging_exam.abstractor_abstraction_groups.first.soft_delete!
      expect(@imaging_exam.reload.abstractor_abstraction_groups_by_namespace.size).to eq(1)
    end

    it 'can filter abstractor abstraction groups by subject group', focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      abstractor_subject_group = @imaging_exam.reload.abstractor_abstraction_groups_by_namespace.first.abstractor_subject_group
      expect(@imaging_exam.abstractor_abstraction_groups_by_namespace(abstractor_subject_group_id: abstractor_subject_group.id).size).to eq(1)
    end

    it "can report abstractions needing to be reviewed (regardless of namespace)", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW).size).to eq(6)
    end

    it "can report abstractions needing to be reviewed in a namespace", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW,namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(3)
    end

    it "can report what has been reviewed (regardless of namespace)", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      abstractor_suggestion = @imaging_exam.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_dat).abstractor_suggestions.first
      abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
      abstractor_suggestion.save

      expect(@imaging_exam.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED).size).to eq(1)
    end

    it "can report what has been reviewed in a namespace", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      abstractor_suggestion = @imaging_exam.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_dat).abstractor_suggestions.first
      abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
      abstractor_suggestion.save

      expect(@imaging_exam.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(1)
    end

    it "does not report what has been reviewed in another namespace", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      abstractor_suggestion = @imaging_exam.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_dat).abstractor_suggestions.first
      abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
      abstractor_suggestion.save

      expect(@imaging_exam.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id).size).to eq(0)
    end

    #removing abstractions
    it "removes abstractions in a namespace", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(3)
      expect(@imaging_exam.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id).size).to eq(3)
      @imaging_exam.remove_abstractions(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(3)
      expect(@imaging_exam.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id).size).to eq(0)
    end

    it "will not remove reviewed abstractions in a namespace (if so instructed)", focus: false do
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      @imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(3)
      @imaging_exam.remove_abstractions(only_unreviewed: true, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(@imaging_exam.reload.abstractor_abstractions_by_namespace(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).size).to eq(3)
    end

    #querying by abstractor abstraction status
    it "can report what needs to be reviewed in a namespace", focus: false do
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_recist_response.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_recist_response.namespace_id)).to eq([@imaging_exam])
    end

    it "only reports what needs to be reviewed in a namespace", focus: false do
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
      @imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([@imaging_exam])
    end

    it "can report what needs to be reviewed in a namespace (ignoring soft deleted rows)", focus: false do
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
      imaging_exam = FactoryGirl.create(:imaging_exam)
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.soft_delete!
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
    end

    it "can report what needs to be reviewed in a namespace (including 'blanked' values)", focus: false do
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
      imaging_exam = FactoryGirl.create(:imaging_exam)
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        expect(abstractor_abstraction.value).to be_nil
        abstractor_abstraction.value = ''
        abstractor_abstraction.save!
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])
    end

    it "can report what has been reviewed in a namespace (including 'blanked' values)", focus: false do
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
      imaging_exam = FactoryGirl.create(:imaging_exam)
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        expect(abstractor_abstraction.value).to be_nil
        abstractor_abstraction.value = ''
        abstractor_abstraction.save!
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
    end

    it "can report what has been reviewed in a namespace", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam)
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])
    end

    it "can report what has been reviewed in a namespace (ignoring soft deletd rows)", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam)
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)
      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to eq([imaging_exam])

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.soft_delete!
      end

      expect(ImagingExam.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED, namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)).to be_empty
    end

    #pivoting groups
    it "can pivot grouped abstractions in a namespace as if regular columns on the abstractable entity", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name:'Dopamine Transporter Level').first

      abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.create(abstractor_subject_group_id: abstractor_subject_group.id, about_type: ImagingExam.to_s, about_id: imaging_exam.id)
      abstractor_abstraction_group.abstractor_subject_group.abstractor_subjects.each do |abstractor_subject|
        abstraction = abstractor_subject.abstractor_abstractions.build(about_id: imaging_exam.id, about_type: ImagingExam.to_s)
        abstraction.build_abstractor_abstraction_group_member(abstractor_abstraction_group: abstractor_abstraction_group)
        abstraction.save!
      end

      pivots = ImagingExam.pivot_grouped_abstractions('Dopamine Transporter Level', namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivots.each do |p|
        expect(p.respond_to?(:has_recist_response_criteria)).to be_falsey
      end
      pivots = pivots.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_dopamine_transporter_level: ie.has_dopamine_transporter_level, has_anatomical_location: ie.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_dopamine_transporter_level: 'Normal', has_anatomical_location: 'parietal lobe' }, {id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number,  has_dopamine_transporter_level: nil, has_anatomical_location: nil } ]))
    end

    it "can pivot grouped abstractions in a namepace as if regular columns on the abstractable entity if the vaue is marked as 'unknown'", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_rejected
        abstractor_suggestion.save
        abstractor_abstraction.unknown = true
        abstractor_abstraction.save!
      end

      pivots = ImagingExam.pivot_grouped_abstractions('Dopamine Transporter Level', namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivots = pivots.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_dopamine_transporter_level: ie.has_dopamine_transporter_level, has_anatomical_location: ie.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_dopamine_transporter_level: 'unknown', has_anatomical_location: 'unknown' } ]))
    end

    it "can pivot grouped abstractions in a namespace as if regular columns on the abstractable entity if the vaue is marked as 'not applicable'", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_rejected
        abstractor_suggestion.save
        abstractor_abstraction.not_applicable = true
        abstractor_abstraction.save!
      end

      pivots = ImagingExam.pivot_grouped_abstractions('Dopamine Transporter Level', namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivots = pivots.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_dopamine_transporter_level: ie.has_dopamine_transporter_level, has_anatomical_location: ie.has_anatomical_location } }
      expect(Set.new(pivots)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_dopamine_transporter_level: 'not applicable', has_anatomical_location: 'not applicable' } ]))
    end

    #pivioting
    it "can pivot abstractions in a namespace as if regular columns on the abstractable entity", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.  Here favorite character is moominpapa.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      pivot = ImagingExam.pivot_abstractions(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivot.each do |p|
        expect(p.respond_to?(:has_favorite_minor_moomin_character)).to be_falsey
      end

      pivot = pivot.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_favorite_major_moomin_character: ie.has_favorite_major_moomin_character } }
      expect(Set.new(pivot)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_favorite_major_moomin_character: 'moominpapa' } ]))
    end

    it "can pivot abstractions in a namespace as if regular columns on the abstractable entity if the vaue is marked as 'unknown'", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.  Here favorite character is moominpapa.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status =   @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        abstractor_suggestion.save
        abstractor_abstraction.unknown = true
        abstractor_abstraction.save!
      end

      pivot = ImagingExam.pivot_abstractions(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivot = pivot.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_favorite_major_moomin_character: ie.has_favorite_major_moomin_character } }
      expect(Set.new(pivot)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_favorite_major_moomin_character: 'unknown' } ]))
    end

    it "can pivot abstractions in a namespace as if regular columns on the abstractable entity if the vaue is marked as 'not applicable'", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.  Here favorite character is moominpapa.', report_date: Date.today, patient_id: 1, accession_number: '123' )
      imaging_exam.abstract(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id)

      imaging_exam.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status =   @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        abstractor_suggestion.save
        abstractor_abstraction.not_applicable = true
        abstractor_abstraction.save!
      end

      pivot = ImagingExam.pivot_abstractions(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivot = pivot.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_favorite_major_moomin_character: ie.has_favorite_major_moomin_character } }
      expect(Set.new(pivot)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_favorite_major_moomin_character: 'not applicable' } ]))
    end

    it "can pivot abstractions in a namespace as if regular columns on the abstractable entity (even if the entity has not been abstracted)", focus: false do
      imaging_exam = FactoryGirl.create(:imaging_exam, note_text: 'DaT scan: normal.  This is good news.  Very healthly looking parietal lobe.  Here favorite character is moominpapa.', report_date: Date.today, patient_id: 1, accession_number: '123' )

      pivot = ImagingExam.pivot_abstractions(namespace_type: @abstractor_subject_abstraction_schema_dat.namespace_type, namespace_id:  @abstractor_subject_abstraction_schema_dat.namespace_id).where(id: imaging_exam.id)
      pivot = pivot.map { |ie| { id: ie.id,  note_text: ie.note_text, patient_id: ie.patient_id, report_date: ie.report_date, accession_number: ie.accession_number, has_favorite_major_moomin_character: ie.has_favorite_major_moomin_character } }
      expect(Set.new(pivot)).to eq(Set.new([{ id: imaging_exam.id,  note_text: imaging_exam.note_text, patient_id: imaging_exam.patient_id, report_date: imaging_exam.report_date, accession_number: imaging_exam.accession_number, has_favorite_major_moomin_character: nil } ]))
    end
  end
end