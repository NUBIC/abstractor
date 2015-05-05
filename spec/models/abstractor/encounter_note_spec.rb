require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe EncounterNote do
  before(:each) do
    Abstractor::Setup.system
    Setup.encounter_note
    @abstractor_abstraction_schema_kps = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_karnofsky_performance_status').first
    @abstractor_subject_abstraction_schema_kps = Abstractor::AbstractorSubject.where(subject_type: EncounterNote.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_kps.id).first
    @list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    @abstractor_abstraction_always_unknown = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: @list_object_type, preferred_name: 'Always unknown')
    @abstractor_subject_abstraction_schema_always_unknown = Abstractor::AbstractorSubject.create(:subject_type => 'EncounterNote', :abstractor_abstraction_schema => @abstractor_abstraction_always_unknown)
    @abstractor_abstraction_schema_kps_date = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_karnofsky_performance_status_date').first
    @abstractor_subject_abstraction_schema_kps_date = Abstractor::AbstractorSubject.where(subject_type: EncounterNote.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_kps_date.id).first
    @source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_abstraction_schema_always_unknown, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, :abstractor_rule_type => unknown_rule)
    @abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first
    @abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
    @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
    @value_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    @name_value_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
  end

  describe "abstracting" do
    it "can report its abstractor subjects", focus: false do
      abstractor_subjects = Abstractor::AbstractorSubject.where(subject_type: EncounterNote.to_s)
      expect(Set.new(EncounterNote.abstractor_subjects)).to eq(Set.new(abstractor_subjects))
    end

    it "can report its abstractor subjects by schemas", focus: false do
      expect(Set.new(EncounterNote.abstractor_subjects(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_kps.id, @abstractor_abstraction_schema_kps_date.id]))).to eq Set.new([@abstractor_subject_abstraction_schema_kps, @abstractor_subject_abstraction_schema_kps_date])
    end

    it "can report its abstractor abstraction schemas", focus: false do
      expect(Set.new(EncounterNote.abstractor_abstraction_schemas)).to eq(Set.new([@abstractor_abstraction_schema_kps, @abstractor_abstraction_always_unknown, @abstractor_abstraction_schema_kps_date]))
    end

    #abstractions
    it "creates a 'has_always_unknown' abstraction for a rule type of 'unknown'", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_always_unknown)).to_not be_nil
    end

    it "creates an abstraction with an suggestion of 'unknown' for a rule type of 'unknown'", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_always_unknown).abstractor_suggestions.first.unknown).to be_truthy
    end

    it "creates a 'has_karnofsky_performance_status' abstraction'", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction upon re-abstraction", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 90.')
      @encounter_note.abstract
      @encounter_note.reload.abstract
      expect(@encounter_note.reload.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_karnofsky_performance_status' }.size).to eq(1)
    end

    it "if abstractor_abstraction_schema_ids parameter is set creates abstraction only for selected schemas" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 90.')
      @encounter_note.abstract(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_kps.id, @abstractor_abstraction_schema_kps_date.id])

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date)).to_not be_nil
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_always_unknown)).to be_nil

      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date)).to_not be_nil
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_always_unknown)).not_to be_nil
    end

    #removing abstractions
    it "can remove abstractions", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      encounter_note.abstract

      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
      encounter_note.remove_abstractions
      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to be_nil
    end

    it "will not remove reviewed abstractions (if so instructed)", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      encounter_note.abstract

      encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
      encounter_note.remove_abstractions
      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
    end

    it "can remove abstractions for specified abstraction schemas", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      encounter_note.abstract

      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to_not be_nil
      encounter_note.remove_abstractions(abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_kps.id, @abstractor_abstraction_schema_kps_date.id])

      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps)).to be_nil
      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date)).to be_nil
      expect(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_always_unknown)).not_to be_nil
    end

    #suggestion suggested value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the canonical name/value format)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the squished canonical name/value format)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the sentential format)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's Karnofsky performance status is 20.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq("20% - Very sick; hospital admission necessary; active supportive treatment necessary.")
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the canonical name/value format)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the sentential format) that is equivalient to a object", focus: false do
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'kps')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @abstractor_abstraction_schema_kps, abstractor_object_value: abstractor_object_value)

      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient has a ?kps")
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to eq('kps')
    end
    #suggestions
    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(1)
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 80')
      @encounter_note.abstract

      expect(Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.']))
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS80')
      @encounter_note.abstract

      expect(Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.']))
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 80.")
      @encounter_note.abstract

      expect(Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.']))
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size).to eq(1)
    end

    #custom suggestions
    it "creates one 'has_karnofsky_performance_status_date' abstraction suggestion (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '2014-06-26'}.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status_date' abstraction suggestion source explanation (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.find { |suggestion| suggestion.suggested_value == '2014-06-26'}.abstractor_suggestion_sources.map(&:custom_explanation)).to eq(["A bit of custom logic."])
    end

    it "does not create another 'has_karnofsky_performance_status_date' abstraction suggestion upon re-abstraction (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.size).to eq(1)
    end

    it "does not create a'has_karnofsky_performance_status_date' abstraction 'unknown' suggestion if the custom rule makes a suggestion (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.select { |suggestion| suggestion.unknown.nil? }.size).to eq(1)
    end

    it "does create a'has_karnofsky_performance_status_date' abstraction 'unknown' suggestion if the custom rule does not make a suggestion (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      abstractor_abstraction_source = @abstractor_subject_abstraction_schema_kps_date.abstractor_abstraction_sources.first
      abstractor_abstraction_source.custom_method = 'empty_encounter_date'
      abstractor_abstraction_source.save!
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.size).to eq(1)
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.select { |suggestion| suggestion.unknown == true }.size).to eq(1)
    end

    #suggestion match value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('karnofsky performance status: 90')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('karnofsky performance status90')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's karnofsky performance status is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq("the patient's karnofsky performance status is 90.")
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('kps: 90')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('kps90')
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract

      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq("the patient's kps is 90.")
    end

    #negation
    it "does not create a 'has_karnofsky_performance_status' abstraction suggestion match value from a negated name (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  No evidence of karnofsky performance status of 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to be_nil
    end

    it "does not create a 'has_karnofsky_performance_status' abstraction suggestion match value from a negated value (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status has no evidence of 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq('karnofsky performance status')
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('karnofsky performance status has no evidence of 90.')
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.suggested_value).to be_nil
    end

    it "does not create a 'has_karnofsky_performance_status' abstraction suggestion match value from a negated name (using the sentential format) even with a negation cue not immiedatley preceeding the target value", focus: false do
      pending "Expected to fail: Need to replace the negation library with something better."
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  No evidence of this thing called karnofsky performance status of 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to be_nil
    end

    #suggestion sources
    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.sentence_match_value == 'kps: 90'}.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.sentence_match_value == 'kps90'}.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.sentence_match_value == "the patient's kps is 90."}.size).to eq(1)
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the canonical name/value format)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(2)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(2)
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
    end

    it "creates one 'has_karnofsky_performance_status_date' abstraction suggestion source (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.first.abstractor_suggestion_sources.first.custom_method).to eq('encounter_date')
    end

    it "does not create another 'has_karnofsky_performance_status_date' abstraction suggestion source upon re-abstraction (using a custom rule)", focus: false do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps_date).abstractor_suggestions.first.abstractor_suggestion_sources.size).to eq(1)
    end

    #abstractor object value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion object value for each suggestion with a suggested value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      object_value = Abstractor::AbstractorObjectValue.where(value: '90% - Able to carry on normal activity; minor signs or symptoms of disease.').first
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_object_value).to eq(object_value)
    end

    #unknowns
    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.unknown).to be_truthy
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value from a preferred name/predicate" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Not sure about his karnofsky performance status.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.unknown).to be_truthy
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq("karnofsky performance status")
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq("not sure about his karnofsky performance status.")
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value from from a predicate variant" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  His kps is probably good.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.unknown).to be_truthy
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq("kps")
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq("his kps is probably good.")
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  His kps is probably good.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.unknown).to be_truthy
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq("kps")
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq("his kps is probably good.")
    end

    it "does not create a 'has_karnofsky_performance_status' abstraction suggestion object value for a unknown abstraction suggestion " do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_object_value).to be_nil
    end

    it "does not creates another 'has_karnofsky_performance_status' unknown abstraction suggestion upon re-abstraction" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.unknown }.size).to eq(1)
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.unknown }.size).to eq(1)
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion source with a match value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS is very good.')
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.unknown).to be_truthy
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq('kps')
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.sentence_match_value).to eq('kps is very good.')
    end

    #new suggestions upon re-abstraction
    it "blanks out the current value of a abstractor abstraction if a new suggestion appears upon re-abstraction " do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first
      abstractor_suggestion_status = Abstractor::AbstractorSuggestionStatus.where(name: 'Accepted').first
      abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status
      abstractor_suggestion.save
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).value).to eq('90% - Able to carry on normal activity; minor signs or symptoms of disease.')
      @encounter_note.note_text = 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 80'
      @encounter_note.save
      @encounter_note.abstract
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.size).to eq(2)
      expect(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).value).to be_nil
    end

    describe "querying by abstractor abstraction status" do
      before(:each) do
        @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
        @encounter_note.abstract
        @encounter_note.reload
      end

      it "can report what needs to be reviewed", focus: false do
        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to eq([@encounter_note])
      end

      it "can report what needs to be reviewed (ignoring soft deleted rows)", focus: false do
        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to  eq([@encounter_note])

        @encounter_note.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_abstraction.soft_delete!
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to be_empty
      end

      it "can report what needs to be reviewed (including 'blanked' values)", focus: false do
        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to eq([@encounter_note])

        @encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
          expect(abstractor_abstraction.value).to be_nil
          abstractor_abstraction.value = ''
          abstractor_abstraction.save!
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to eq([@encounter_note])
      end

      it "can report what has been reviewed (including 'blanked' values)", focus: false do
        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW)).to eq([@encounter_note])

        @encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
          expect(abstractor_abstraction.value).to be_nil
          abstractor_abstraction.value = ''
          abstractor_abstraction.save!
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED)).to eq([])
      end

      it "can report what has been reviewed", focus: false do
        @encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
          abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
          abstractor_suggestion.save
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED)).to eq([@encounter_note])
      end

      it "can report what has been reviewed (ignoring soft deletd rows)", focus: false do
        @encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
          abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
          abstractor_suggestion.save
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED)).to eq([@encounter_note])

        @encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_abstraction.soft_delete!
        end

        expect(EncounterNote.by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED)).to be_empty
      end

      it "can report what needs to be reviewed for an instance", focus: false do
        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW).size).to eq(3)
      end

      it "can report what has been reviewed for an instance", focus: false do
        abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save

        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED).size).to eq(1)
      end

      it "can report what needs to be reviewed for an instance (ignoring soft deleted rows)", focus: false do
        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW).size).to eq(3)
        @encounter_note.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_abstraction.soft_delete!
        end
        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW).size).to eq(0)
      end

      it "can report what has been reviewed for an instance (ignoring soft deleted rows)", focus: false do
        abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_kps).abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save

        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED).size).to eq(1)

        @encounter_note.abstractor_abstractions.each do |abstractor_abstraction|
          abstractor_abstraction.soft_delete!
        end
        expect(@encounter_note.reload.abstractor_abstractions_by_abstractor_abstraction_status(Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED).size).to eq(0)
      end
    end

    #pivioting
    it "can pivot abstractions as if regular columns on the abstractable entity", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      encounter_note.abstract

      encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save
      end

      pivot = EncounterNote.pivot_abstractions.where(id: encounter_note.id).map { |en| { id: en.id, note_text: en.note_text, has_karnofsky_performance_status: en.has_karnofsky_performance_status } }
      expect(pivot).to eq([{ id: encounter_note.id, note_text: encounter_note.note_text, has_karnofsky_performance_status: "90% - Able to carry on normal activity; minor signs or symptoms of disease." }])
    end

    it "can pivot abstractions as if regular columns on the abstractable entity if the vaue is marked as 'unknown'", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      encounter_note.abstract

      encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status =   @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        abstractor_suggestion.save
        abstractor_abstraction.unknown = true
        abstractor_abstraction.save!
      end

      pivot = EncounterNote.pivot_abstractions.where(id: encounter_note.id).map { |en| { id: en.id, note_text: en.note_text, has_karnofsky_performance_status: en.has_karnofsky_performance_status } }
      expect(pivot).to eq([{ id: encounter_note.id, note_text: encounter_note.note_text, has_karnofsky_performance_status: 'unknown' }])
    end

    it "can pivot abstractions as if regular columns on the abstractable entity if the vaue is marked as 'not applicable'", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      encounter_note.abstract

      encounter_note.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_suggestion = abstractor_abstraction.abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status =   @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        abstractor_suggestion.save
        abstractor_abstraction.not_applicable = true
        abstractor_abstraction.save!
      end

      pivot = EncounterNote.pivot_abstractions.where(id: encounter_note.id).map { |en| { id: en.id, note_text: en.note_text, has_karnofsky_performance_status: en.has_karnofsky_performance_status } }
      expect(pivot).to eq([{ id: encounter_note.id, note_text: encounter_note.note_text, has_karnofsky_performance_status: 'not applicable' }])
    end

    it "can pivot abstractions as if regular columns on the abstractable entity (even if the entity has not been abstracted)", focus: false do
      encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      pivot = EncounterNote.pivot_abstractions.where(id: encounter_note.id).map { |en| { id: en.id, note_text: en.note_text, has_karnofsky_performance_status: en.has_karnofsky_performance_status } }
      expect(pivot).to eq([{ id: encounter_note.id, note_text: encounter_note.note_text, has_karnofsky_performance_status: nil }])
    end

    describe 'grouped abstractions' do
      before(:each) do
        @family_subject_group  = Abstractor::AbstractorSubjectGroup.where(name: 'Family history of movement disorder', subtype: 'sentinental').first_or_create
        items_count = 0

        @relative_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where( predicate: 'has_relative_with_movement_disorder_relative', display_name: 'Relative', abstractor_object_type: @list_object_type, preferred_name: 'Relative').first_or_create
        abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Biological Mother').first_or_create
        ['mother','mom'].each do |variant|
          Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: variant).first_or_create
        end
        Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: @relative_abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create

        abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'Biological Father').first_or_create
        ['father','dad'].each do |variant|
          Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: variant).first_or_create
        end

        Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: @relative_abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create
        ['Full', 'Half'].each do |value|
          abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: "#{value} Sibling").first_or_create
          ['sister', 'sisters', 'brother', 'brothers', 'sibling', 'siblings'].each do |variant|
            if value == 'Full'
              Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: variant).first_or_create
            else
              Abstractor::AbstractorObjectValueVariant.where(abstractor_object_value: abstractor_object_value, value: value + ' ' + variant).first_or_create
            end
          end
          Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: @relative_abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create
        end

        abstractor_subject = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)

        items_count = items_count + 1
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        @disorder_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where( predicate: 'has_relative_with_movement_disorder_disorder', display_name: 'Disorder', abstractor_object_type: @list_object_type, preferred_name: 'Disorder').first_or_create

        ['parkinsonism', 'tremor', 'Essential tremor', 'pd'].each do |value|
          abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: value).first_or_create
          Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create
        end

        abstractor_subject = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)

        items_count = items_count + 1
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create
      end

      it 'detects sentinental groups' do
        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
        encounter_note_1.abstract

        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
        encounter_note_2.abstract

        expect(Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).count).to eq 6

        # first abstracted note should be intact
        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second abstracted note should have a full set of abstractions
        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end
      end

      it 'removes unused abstractions' do
        note_text = "Mother - died age 70, cardiac problems, no neurologic problem\nFather - died age 75, \"PD\" diagnosis, had abnormal movements in his 70s"
        encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
        encounter_note_1.abstract

        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 1

        expect(Abstractor::AbstractorAbstraction.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).length).to eq 2
      end

      it 're-abstracts sentinental groups' do
        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
        encounter_note_1.abstract
        encounter_note_1.abstract

        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
        encounter_note_2.abstract
        encounter_note_2.abstract
        # first abstracted note should be intact
        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second abstracted note should have a full set of abstractions
        abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
        expect(abstractor_abstraction_groups.count).to eq 3
        abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq @family_subject_group.abstractor_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end
      end

      it 'respects namespacing in sentinental groups' do
        items_count = 0
        abstractor_subject_1_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = items_count + 1
        abstractor_subject_1_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = 0
        abstractor_subject_2_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = items_count + 1
        abstractor_subject_2_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        namespace_1_subjects = @family_subject_group.abstractor_subjects.where(namespace_type: 'Discerner::Search', namespace_id: 1)
        namespace_2_subjects = @family_subject_group.abstractor_subjects.where(namespace_type: 'Discerner::Search', namespace_id: 2)


        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)

        # abstract first note in first namespace
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 3

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 0

        # abstract first note in second namespace
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # additional set of abstractions in namespace 2
        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)

        # abstract second note in first namespace
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

        # first note should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second note should have a full set of abstractions in the first namespace
        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 3

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 0

        # abstract second note in second namespace
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
        # first note should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # first namespace should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second note should have an additional full set of abstractions
        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end
      end

      it 're-abstracts namespaced sentinental groups' do
        items_count = 0
        abstractor_subject_1_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = items_count + 1
        abstractor_subject_1_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = 0
        abstractor_subject_2_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        items_count = items_count + 1
        abstractor_subject_2_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
        Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
        Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

        namespace_1_subjects = @family_subject_group.abstractor_subjects.where(namespace_type: 'Discerner::Search', namespace_id: 1)
        namespace_2_subjects = @family_subject_group.abstractor_subjects.where(namespace_type: 'Discerner::Search', namespace_id: 2)


        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)

        # abstract first note in first namespace
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 3

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 0

        # abstract first note in second namespace
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
        encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # additional set of abstractions in namespace 2
        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        note_text = "Family Hx: Mother - died from CHF, dementia in later years; Dad - pancreatic cancer , DM 2 sisters with DM, 1 of those with schizophrenia. Dad and sister with parkinsonism. DM, MI in siblings.\nHer father had a tremor and was diagnosed with parkinsonism. He was not treated for it. She also has a sister who lives in nursing home that has asymmetric tremor and suspected parkinsonism, but is not being treated either. Of note, she also has a hx of schizophrenia that is being treated with AP."
        encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)

        # abstract second note in first namespace
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

        # first note should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second note should have a full set of abstractions in the first namespace
        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 3

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 0

        # abstract second note in second namespace
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
        encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
        # first note should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        # first namespace should not be affected
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # first namespace should not be affected
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        # second note should have an additional full set of abstractions
        # total number of groups
        all_abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id).any?}
        expect(all_abstractor_abstraction_groups.count).to eq 6

        namespace_1_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_1_subjects.map(&:id)).any?}
        expect(namespace_1_abstractor_abstraction_groups.count).to eq 3
        namespace_1_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end

        namespace_2_abstractor_abstraction_groups = all_abstractor_abstraction_groups.select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(abstractor_subject_id: namespace_2_subjects.map(&:id)).any?}
        expect(namespace_2_abstractor_abstraction_groups.count).to eq 3
        namespace_2_abstractor_abstraction_groups.each do |abstractor_abstraction_group|
          expect(abstractor_abstraction_group.abstractor_abstractions.length).to eq namespace_1_subjects.length

          abstractor_suggestion_sources = Abstractor::AbstractorSuggestionSource.joins(abstractor_suggestion: { abstractor_abstraction: :abstractor_abstraction_group})
            .where(abstractor_abstraction_groups: { id: abstractor_abstraction_group.id}, abstractor_suggestions: { unknown: nil})

          expect(abstractor_suggestion_sources.select(:sentence_match_value).distinct.map(&:sentence_match_value).length).to eq 1
        end
      end

      describe 'it leaves default group intact' do
        it 'if no sentinental subgroups detected' do
          note_text = "Hello, world"
          encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_1.abstract

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_2.abstract

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1
        end

        it 'if no complete sentinental subgroups detected' do
          note_text = "Hello, father"
          encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_1.abstract

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_2.abstract

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1
        end

        it 'respects namespacing in sentinental groups if no sentinental subgroups detected' do
          items_count = 0
          abstractor_subject_1_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = items_count + 1
          abstractor_subject_1_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = 0
          abstractor_subject_2_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = items_count + 1
          abstractor_subject_2_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          note_text = "Hello, world"
          encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2
        end

        it 'respects namespacing in sentinental groups if no complete sentinental subgroups detected' do
          items_count = 0
          abstractor_subject_1_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = items_count + 1
          abstractor_subject_1_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_1_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_1_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = 0
          abstractor_subject_2_1 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @relative_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_1, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_1, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          items_count = items_count + 1
          abstractor_subject_2_2 = Abstractor::AbstractorSubject.where( subject_type: 'EncounterNote', abstractor_abstraction_schema: @disorder_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2).first_or_create
          Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject_2_2, from_method: 'note_text', abstractor_abstraction_source_type: @source_type_nlp_suggestion, abstractor_rule_type: @value_rule)
          Abstractor::AbstractorSubjectGroupMember.where(abstractor_subject: abstractor_subject_2_2, abstractor_subject_group: @family_subject_group, display_order: items_count).first_or_create

          note_text = "Hello, father"
          encounter_note_1 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_1.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          encounter_note_2 = FactoryGirl.create(:encounter_note, note_text: note_text)
          encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 1

          encounter_note_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_1.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2

          abstractor_abstraction_groups = Abstractor::AbstractorAbstractionGroup.where(abstractor_subject_group_id: @family_subject_group.id).select{|abstractor_abstraction_group| abstractor_abstraction_group.abstractor_abstractions.where(about_id: encounter_note_2.id, abstractor_subject_id: @family_subject_group.abstractor_subjects.map(&:id)).any?}
          expect(abstractor_abstraction_groups.count).to eq 2
        end
      end
    end
  end
end