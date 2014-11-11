require 'spec_helper'
describe  Abstractor::AbstractorAbstractionSource do
  before(:each) do
    Abstractor::Setup.system
    @list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    @value_rule_type = Abstractor::AbstractorRuleType.where(name: 'value').first
    @source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    @abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: @list_object_type, preferred_name: 'some property')
    @abstractor_subject = FactoryGirl.create(:abstractor_subject, subject_type: 'EncounterNote', abstractor_abstraction_schema: @abstractor_abstraction_schema)
    @encounter_note = FactoryGirl.create(:encounter_note, note_text: 'Little my says hi!')
  end

  it "can normalize its from method from a string", focus: false do
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'note_text')
    expect(abstractor_abstraction_source.normalize_from_method_to_sources(@encounter_note)).to eq([ { source_type: EncounterNote, source_id: @encounter_note.id, source_method: "note_text", section_name: nil }])
  end

  it "can normalize its from method when the method returns nil", focus: false do
    encounter_note = FactoryGirl.create(:encounter_note, note_text: "can't be nil")
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'custom_method_nil')
    expect(abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note)).to eq([{ source_type: EncounterNote, source_id: encounter_note.id, source_method: "custom_method_nil", section_name: nil }])
  end

  it "can normalize its from method when it is nil", focus: false do
    encounter_note = FactoryGirl.create(:encounter_note, note_text: "can't be nil")
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: nil)
    expect(abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note)).to eq([{ source_type: EncounterNote, source_id: encounter_note.id, source_method: nil, section_name: nil }])
  end

  it "can normalize its from method from a custom method", focus: false do
    abstractor_abstraction_source = FactoryGirl.create(:abstractor_abstraction_source, abstractor_subject: @abstractor_subject, from_method: 'custom_method')
    expect(abstractor_abstraction_source.normalize_from_method_to_sources(@encounter_note)).to eq([{ source_type: nil, source_id: nil, source_method: nil }])
  end

  describe 'sections' do
    before(:each) do
      Abstractor::Setup.system
      @list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      @value_rule_type = Abstractor::AbstractorRuleType.where(name: 'value').first
      @source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @abstractor_abstraction_schema_moomin = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_favorite_moomin', display_name: 'Has favorite moomin', abstractor_object_type_id: @list_object_type.id, preferred_name: 'Has favorite moomin').first_or_create

      ['Moomintroll', 'Little My', 'The Groke'].each do |moomin|
        abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: moomin)
        Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @abstractor_abstraction_schema_moomin, abstractor_object_value: abstractor_object_value)
      end

      @abstractor_subject_moomin = Abstractor::AbstractorSubject.create(subject_type: 'EncounterNote', abstractor_abstraction_schema: @abstractor_abstraction_schema_moomin)
    end

    it 'across the complete source note if no section is specified', focus: false do
    note_text=<<EOS
I like little my the best!
favorite moomin:
The groke is the bomb!
EOS
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion)
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq(note_text)
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(["Little My", "The Groke"]))
    end

    it 'across a section of the source note based on a name/value section type', focus: false do
    note_text=<<EOS
I like little my the best!
favorite moomin:
The groke is the bomb!
EOS

      abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first
      abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'EncounterNote', source_method: 'note_text', name: 'favorite moomin', delimiter: ':')
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion, section_name: 'favorite moomin')
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq("\nThe groke is the bomb!\n")
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(["The Groke"]))
    end

    it 'across the complete source note based on a name/value section type if a section cannot be found and is instructed to return the whole note upon no match', focus: false do
    note_text=<<EOS
I like little my the best!
cool moomin character:
The groke is the bomb!
EOS

      abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first
      abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'EncounterNote', source_method: 'note_text', name: 'favorite moomin', return_note_on_empty_section: true, delimiter: ':')
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion, section_name: 'favorite moomin')
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq(note_text)
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(["Little My", "The Groke"]))
    end

    it 'across an empty note based on a name/value section type if a section cannot be found and is instructed to not return the whole note upon no match', focus: false do
    note_text=<<EOS
I like little my the best!
favorite moomin character:
The groke is the bomb!
EOS

      abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first
      abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'EncounterNote', source_method: 'note_text', name: 'favorite moomin', return_note_on_empty_section: false, delimiter: ':')
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion, section_name: 'favorite moomin')
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq('')
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new([nil]))
    end

    it 'across a section of the source note based on a name/value section type name varaint', focus: false do
    note_text=<<EOS
I like little my the best!
beloved moomin:
The groke is the bomb!
EOS

      abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first
      abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'EncounterNote', source_method: 'note_text', name: 'favorite moomin', delimiter: ':')
      abstractor_section_name_varaint = Abstractor::AbstractorSectionNameVariant.create(abstractor_section: abstractor_section, name: 'beloved moomin')
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion, section_name: 'favorite moomin')
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq("\nThe groke is the bomb!\n")
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(["The Groke"]))
    end

    it 'across a section of the source note based on a custom section type', focus: true do
    note_text=<<EOS
I like little my the best!
Bad ass moomin--
The groke is the bomb!
EOS

      abstractor_section_type_name_value = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_CUSTOM).first
      abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_name_value, source_type: 'EncounterNote', source_method: 'note_text', name: 'favorite moomin', custom_regular_expression: "(?<=^|[\r\n])([A-Z][^delimiter]*)delimiter([^\r\n]*(?:[\r\n]+(?![A-Z].*delimiter).*)*)", delimiter: '--')
      abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_moomin, from_method: 'note_text', abstractor_rule_type: @value_rule_type, abstractor_abstraction_source_type: @source_type_nlp_suggestion, section_name: 'favorite moomin')
      encounter_note = FactoryGirl.create(:encounter_note, note_text: note_text)
      source = abstractor_abstraction_source.normalize_from_method_to_sources(encounter_note).first
      encounter_note.abstract
      expect(Abstractor::AbstractorAbstractionSource.abstractor_text(source)).to eq("\nThe groke is the bomb!\n")
      expect(Set.new(encounter_note.reload.detect_abstractor_abstraction(@abstractor_subject_moomin).abstractor_suggestions.map(&:suggested_value))).to eq(Set.new(["The Groke"]))
    end
  end
end