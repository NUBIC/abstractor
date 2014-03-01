require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe RadiationTherapyPrescription do
  before(:all) do
    Setup.sites
    Setup.custom_site_synonyms
    Setup.site_categories
    Setup.laterality
    Abstractor::Setup.system
    Setup.radiation_therapy_prescription
    @abstractor_abstraction_schema_has_anatomical_location = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_anatomical_location').first
    @abstractor_abstraction_schema_has_laterality = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_laterality').first
    @abstractor_subject_abstraction_schema_has_anatomical_location = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_anatomical_location.id).first
    @abstractor_subject_abstraction_schema_has_laterality = Abstractor::AbstractorSubject.where(subject_type: RadiationTherapyPrescription.to_s, abstractor_abstraction_schema_id: @abstractor_abstraction_schema_has_laterality.id).first
  end

  before(:each) do
    @radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription)
  end

  describe "abstracting" do
    it "can report its abstractor subject groups" do
      abstractor_subject_groups = Abstractor::AbstractorSubjectGroup.where(name:'Anatomical Location')
      RadiationTherapyPrescription.abstractor_subject_groups.should_not be_empty
      Set.new(RadiationTherapyPrescription.abstractor_subject_groups).should == Set.new(abstractor_subject_groups)
    end

    #abstractions
    it "creates a 'has_anatomical_location' abstraction'" do
      @radiation_therapy_prescription.abstract
      @radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).should_not be_nil
    end

    it "does not create another 'has_anatomical_location' abstraction upon re-abstraction" do
      @radiation_therapy_prescription.abstract
      @radiation_therapy_prescription.reload.abstractor_abstractions.select { |abstraction| abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_anatomical_location' }.size.should == 1
    end

    it "creates a 'has_laterality' abstraction'" do
      @radiation_therapy_prescription.abstract
      @radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_laterality).should_not be_nil
    end

    it "does not create another 'has_laterality' abstraction upon re-abstraction" do
      @radiation_therapy_prescription.abstract
      @radiation_therapy_prescription.reload.abstractor_abstractions.select { |abstractor_abstraction| abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.predicate == 'has_laterality' }.size.should == 1
    end

    #suggestion suggested value
    it "creates a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.suggested_value.should == 'parietal lobe'
    end

    it "creates a 'has_anatomical_location' abstraction suggestion suggested value from an abstractor object value variant" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.suggested_value.should == 'parietal lobe'
    end

    #suggestion match value
    it "creates a 'has_anatomical_location' abstraction suggestion match value from a from an abstractor object value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'left parietal lobe'
    end

    it "creates a 'has_anatomical_location' abstraction suggestion match value from a from an abstractor object value variant" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should == 'left parietal'
    end

    it "creates multiple 'has_anatomical_location' abstraction suggestion match values given multiple different matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Let me remind you that it is the left parietal.')
      radiation_therapy_prescription.abstract
      Set.new(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.map(&:match_value)).should  == Set.new(["left parietal lobe.", "let me remind you that it is the left parietal."])
    end

    #suggestions
    it "does not create another 'has_anatomical_location' abstraction suggestion upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.size.should == 1
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.size.should == 1
    end

    it "creates multiple 'has_anatomical_location' abstraction suggestions given multiple different matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe and bilateral cerebral meninges')
      radiation_therapy_prescription.abstract

      Set.new(radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.map(&:suggested_value)).should == Set.new(['cerebral meninges', 'parietal lobe', 'meninges'])
    end

    it "creates one 'has_anatomical_location' abstraction suggestion given multiple identical matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Let me remend you that it is the left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.suggested_value == 'parietal lobe'}.size.should == 1
    end

    #negation
    it "does not create a 'has_anatomical_location' abstraction suggestion match value from a negated value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Not the left parietal lobe.')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value.should be_nil
    end

    #suggestion sources
    it "creates one 'has_anatomical_location' abstraction suggestion source given multiple identical matches" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Left parietal lobe.  Talk about some other stuff.  Left parietal lobe.')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.abstractor_suggestion_sources.first.match_value == 'left parietal lobe.'}.size.should == 1
    end

    it "does not create another 'has_anatomical_location' abstraction suggestion source upon re-abstraction (using the canonical name/value format)" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_suggestion_sources.size.should == 1
    end

    #abstractor object value
    it "creates a 'has_anatomical_location' abstraction suggestion object value for each suggestion with a suggested value" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: 'parietal lobe').first
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_object_value.should == abstractor_object_value
    end

    #unknowns
    it "creates a 'has_anatomical_location' unknown abstraction suggestion" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.unknown.should be_true
    end

    it "does not create a 'has_anatomical_location' abstraction suggestion object value for a unknown abstraction suggestion " do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.first.abstractor_object_value.should be_nil
    end

    it "does not creates another 'has_anatomical_location' unknown abstraction suggestion upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'Forgot to mention an anatomical location.')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.unknown }.size.should == 1
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.detect_abstractor_abstraction(@abstractor_subject_abstraction_schema_has_anatomical_location).abstractor_suggestions.select { |abstractor_suggestion| abstractor_suggestion.unknown }.size.should == 1
    end

    #groups
    it "creates a abstractor abstraction group" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.size.should == 1
    end

    it "does not creates another abstractor abstraction group upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      radiation_therapy_prescription.reload.abstract
      radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.size.should == 1
    end

    it "creates a abstractor abstraction group member for each abstractor abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.size.should == 2
    end

    it "does create duplicate abstractor abstraction grup members upon re-abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      radiation_therapy_prescription.reload.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.size.should == 2
    end

    it "creates a abstractor abstraction group member of the right kind for each abstractor abstraction" do
      radiation_therapy_prescription = FactoryGirl.create(:radiation_therapy_prescription, site_name: 'left parietal lobe')
      radiation_therapy_prescription.abstract
      abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: 'Anatomical Location').first
      Set.new(radiation_therapy_prescription.reload.abstractor_abstraction_groups.select { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group == abstractor_subject_group }.first.abstractor_abstractions.map(&:abstractor_abstraction_schema)).should == Set.new([@abstractor_abstraction_schema_has_anatomical_location, @abstractor_abstraction_schema_has_laterality])
    end
  end
end