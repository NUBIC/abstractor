require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe EncounterNote do
  before(:all) do
    Abstractor::Setup.system
    Setup.encounter_note
    @abstractor_abstraction_schema_kps = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_karnofsky_performance_status').first

    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    @always_unknown_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: list_object_type, preferred_name: 'Always unknown')
    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'EncounterNote', :abstractor_abstraction_schema => @always_unknown_abstraction_schema, :abstractor_rule_type => unknown_rule)
  end

  describe "abstracting" do
    it "can report its abstractor subjects" do
      abstractor_subjects = Abstractor::AbstractorSubject.where(subject_type: EncounterNote.to_s)
      Set.new(EncounterNote.abstractor_subjects).should == Set.new(abstractor_subjects)
    end

    it "can report its abstractor abstraction schemas" do
      Set.new(EncounterNote.abstractor_abstraction_schemas).should == Set.new([@abstractor_abstraction_schema_kps, @always_unknown_abstraction_schema])
    end

    #abstractions
    it "creates a 'has_always_unknown' abstraction for a rule type of 'unknown'" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@always_unknown_abstraction_schema).should_not be_nil
    end

    it "creates an abstraction with an suggestion of 'unknown' for a rule type of 'unknown'" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@always_unknown_abstraction_schema).abstractor_suggestions.size.should == 0
      # @encounter_note.reload.detect_abstractor_abstraction(@always_unknown_abstraction_schema).abstractor_suggestions.first.unknown.should_not be_
    end

    it "creates a 'has_karnofsky_performance_status' abstraction'" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 20.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).should_not be_nil
    end

    it "does not FactoryGirl.create another 'has_karnofsky_performance_status' abstraction upon re-abstraction" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  kps: 90.')
      @encounter_note.abstract
      @encounter_note.reload.abstract
      @encounter_note.reload.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_karnofsky_performance_status' }.size.should == 1
    end

    #suggestion suggested value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a preferred name/predicate (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's Karnofsky performance status is 20.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == "20% - Very sick; hospital admission necessary; active supportive treatment necessary."
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion suggested value from a predicate variant (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
    end

    #suggestions
    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
    end

    it "does not create another 'has_karnofsky_performance_status' abstraction suggestion upon re-abstraction (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 1
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 80')
      @encounter_note.abstract

      Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value)).should == Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.'])
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS80')
      @encounter_note.abstract

      Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value)).should == Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.'])
    end

    it "creates multiple 'has_karnofsky_performance_status' abstraction suggestions given multiple different matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 80.")
      @encounter_note.abstract

      Set.new(@encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.map(&:suggested_value)).should == Set.new(['90% - Able to carry on normal activity; minor signs or symptoms of disease.', '80% - Normal activity with effort; some signs or symptoms of disease.'])
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size.should == 1
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size.should == 1
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion given multiple identical matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 90.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.suggested_value == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'}.size.should == 1
    end

    #suggestion match value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'karnofsky performance status: 90'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'karnofsky performance status90'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a preferred name/predicate (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's karnofsky performance status is 90.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == "the patient's karnofsky performance status is 90."
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'kps: 90'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'kps90'
    end

    it "creates a 'has_karnofsky_performance_status' abstraction suggestion match value from a predicate variant (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract

      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == "the patient's kps is 90."
    end

    #negation
    it "does not FactoryGirl.create a 'has_karnofsky_performance_status' abstraction suggestion match value from a negated name (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  No evidence of karnofsky performance status of 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should be_nil
    end

    it "does not FactoryGirl.create a 'has_karnofsky_performance_status' abstraction suggestion match value from a negated value (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status has no evidence of 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'karnofsky performance status'
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.suggested_value.should be_nil
    end

    #suggestion sources
    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.match_value == 'kps: 90'}.size.should == 1
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.  Let me repeat.  KPS90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.match_value == 'kps90'}.size.should == 1
    end

    it "creates one 'has_karnofsky_performance_status' abstraction suggestion source given multiple identical matches (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.  Let me repeat.  The patient's kps is 90.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.abstractor_suggestion_sources.first.match_value == "the patient's kps is 90."}.size.should == 1
    end

    it "does not FactoryGirl.create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 2
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 2
    end

    it "does not FactoryGirl.create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the squished canonical name/value format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS90.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
    end

    it "does not FactoryGirl.create another 'has_karnofsky_performance_status' abstraction suggestion source upon re-abstraction (using the sentential format)" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: "The patient looks healthy.  The patient's kps is 90.")
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
    end

    #abstractor object value
    it "creates a 'has_karnofsky_performance_status' abstraction suggestion object value for each suggestion with a suggested value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Karnofsky performance status: 90.')
      @encounter_note.abstract
      object_value = Abstractor::AbstractorObjectValue.where(value: '90% - Able to carry on normal activity; minor signs or symptoms of disease.').first
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_object_value.should == object_value
    end

    #unknowns
    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.unknown.should be_true
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value from a preferred name/predicate" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  Not sure about his karnofsky performance status.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.unknown.should be_true
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == "karnofsky performance status"
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value from from a predicate variant" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  His kps is probably good.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.unknown.should be_true
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == "kps"
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion match value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  His kps is probably good.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.unknown.should be_true
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == "kps"
    end

    it "does not FactoryGirl.create a 'has_karnofsky_performance_status' abstraction suggestion object value for a unknown abstraction suggestion " do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_object_value.should be_nil
    end

    it "does not FactoryGirl.creates another 'has_karnofsky_performance_status' unknown abstraction suggestion upon re-abstraction" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.unknown }.size.should == 1
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.select { |suggestion| suggestion.unknown }.size.should == 1
    end

    it "creates a 'has_karnofsky_performance_status' unknown abstraction suggestion with a abstraction suggestion source with a match value" do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS is very good.')
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.unknown.should be_true
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'kps'
    end

    #new suggestions upon re-abstraction
    it "blanks out the current value of a abstractor abstraction if a new suggestion appears upon re-abstraction " do
      @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
      @encounter_note.abstract

      abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first
      abstractor_suggestion_status = Abstractor::AbstractorSuggestionStatus.where(name: 'Accepted').first
      abstractor_suggestion.abstractor_suggestion_status = abstractor_suggestion_status
      abstractor_suggestion.save
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).value.should == '90% - Able to carry on normal activity; minor signs or symptoms of disease.'
      @encounter_note.note_text = 'The patient looks healthy.  KPS: 90.  Let me repeat.  KPS: 80'
      @encounter_note.save
      @encounter_note.abstract
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.size.should == 2
      @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).value.should be_nil
    end

    describe "querying by abstractor suggestion status" do
      before(:each) do
        @abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first
        @abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
        @abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
        @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'The patient looks healthy.  KPS: 90.')
        @encounter_note.abstract
      end

      it "can report what needs to be reviewed" do
        EncounterNote.by_abstractor_suggestion_status('needs_review').should == [@encounter_note]
      end

      it "can report what has been reviewed" do
        abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save

        EncounterNote.by_abstractor_suggestion_status('reviewed').should == [@encounter_note]
      end

      it "can report what needs to be reviewed for an instance" do
        @encounter_note.reload.abstractor_abstractions_by_abstractor_suggestion_status([@abstractor_suggestion_status_needs_review]).size.should == 1
      end

      it "can report what has been reviewed for an instance" do
        abstractor_suggestion = @encounter_note.reload.detect_abstractor_abstraction(@abstractor_abstraction_schema_kps).abstractor_suggestions.first
        abstractor_suggestion.abstractor_suggestion_status = @abstractor_suggestion_status_accepted
        abstractor_suggestion.save

        @encounter_note.reload.abstractor_abstractions_by_abstractor_suggestion_status([@abstractor_suggestion_status_accepted, @abstractor_suggestion_status_rejected]).size.should == 1
      end
    end
  end
end