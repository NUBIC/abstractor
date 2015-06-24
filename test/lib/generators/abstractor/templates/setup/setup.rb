require 'csv'
module Setup
  def self.map_site_level(level)
    if ['incl','b','k'].any? { |l| l == level }
      4
    else
      level.to_i
    end
  end

  def self.site_synonym?(level)
    if ['incl','b','k'].any? { |l| l == level }
      true
    else
      false
    end
  end

  def self.sites
    #http://www.who.int/classifications/icd/adaptations/oncology/en/
    sites = CSV.new(File.open('lib/setup/data/ICD-O-3_CSV-metadata/Topoenglish.csv'), headers: true, col_sep:',', return_headers: false)
    sites.each do |row|
      if Site.where(icdo3_code: row.to_hash['Kode'], name: row.to_hash['Title'].downcase).empty?
        Site.create!(icdo3_code: row.to_hash['Kode'], level: Setup.map_site_level(row.to_hash['Lvl']), name: row.to_hash['Title'].downcase, synonym: Setup.site_synonym?(row.to_hash['Lvl'])) if (row.to_hash['Lvl'] == '3' || row.to_hash['Lvl'] == '4' ||  row.to_hash['Lvl'] == 'incl')
      else
        puts 'little my says it already exists!'
      end
    end
  end

  def self.custom_site_synonyms
    site_synonyms = CSV.new(File.open('lib/setup/data/custom_site_synonyms.csv'), headers: true, col_sep:',', return_headers: false)
    site_synonyms.each do |row|
      if Site.where(icdo3_code: row.to_hash['icdo3_code'], level: 4, name: row.to_hash['name'].downcase, synonym: true).empty?
        Site.create!(icdo3_code: row.to_hash['icdo3_code'], level: 4, name: row.to_hash['name'].downcase, synonym: true)
      else
        puts 'little my says it already exists!'
      end
    end
  end

  def self.site_categories
    site_categories = CSV.new(File.open('lib/setup/data/site_site_categories.txt'), headers: true, col_sep:"\t", return_headers: false)
    site_categories.each do |row|
      site_category= SiteCategory.where(name: row.to_hash['site_category']).first
      if site_category.blank?
        site_category = SiteCategory.create!(name: row.to_hash['site_category'])
      end

      Site.where(icdo3_code: row.to_hash['icdo3_code']).each do |site|
        site.site_categories << site_category unless site.site_categories.include?(site_category)
      end
    end
  end

  def self.laterality
    laterals = CSV.new(File.open('lib/setup/data/icdo3_sites_with_laterality.txt'), headers: true, col_sep:"\t", return_headers: false)
    laterals.each do |row|
      site = Site.where(icdo3_code: row.to_hash['icdo3_code'], synonym: false).first
      site.laterality = true
      site.save!
    end
  end

  def self.abstractor_abstraction_schema_anatomical_location
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    anatomical_location_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_anatomical_location').first
    if anatomical_location_abstractor_abstraction_schema.blank?
      anatomical_location_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_anatomical_location', display_name: 'Anatomical location', abstractor_object_type: list_object_type, preferred_name: 'Anatomical location')
      Site.where(synonym: false).each do |site|
        object_value = Abstractor::AbstractorObjectValue.create(value: site.name)
        Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: anatomical_location_abstractor_abstraction_schema, abstractor_object_value: object_value)
        Site.where(icdo3_code: site.icdo3_code, synonym: true).each do |site_synonym|
          Abstractor::AbstractorObjectValueVariant.create(abstractor_object_value: object_value, value: site_synonym.name)
        end
      end
    end
    anatomical_location_abstractor_abstraction_schema
  end

  def self.abstractor_abstraction_schema_laterality
    radio_button_list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST).first
    laterality_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_laterality').first
    if laterality_abstractor_abstraction_schema.blank?
      laterality_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_laterality', display_name: 'Laterality', abstractor_object_type: radio_button_list_object_type, preferred_name: 'Laterality')
      left_ov       = Abstractor::AbstractorObjectValue.create(value: 'left')
      right_ov      = Abstractor::AbstractorObjectValue.create(value: 'right')
      bilateral_ov = Abstractor::AbstractorObjectValue.create(value: 'bilateral')

      laterals = [left_ov, right_ov, bilateral_ov]

      laterals.each do |object_value|
        Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: laterality_abstractor_abstraction_schema, abstractor_object_value: object_value)
      end
    end
    laterality_abstractor_abstraction_schema
  end

  def self.radiation_therapy_prescription
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    radio_button_list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_RADIO_BUTTON_LIST).first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    anatomical_location_abstractor_abstraction_schema = Setup.abstractor_abstraction_schema_anatomical_location
    location_group  = Abstractor::AbstractorSubjectGroup.create(name: 'Anatomical Location')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'RadiationTherapyPrescription', abstractor_abstraction_schema: anatomical_location_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: location_group, display_order: 1)
    laterality_abstractor_abstraction_schema = Setup.abstractor_abstraction_schema_laterality
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'RadiationTherapyPrescription', abstractor_abstraction_schema: laterality_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: location_group, display_order: 2)

    date_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_DATE).first
    unknown_rule_type = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    prescription_date_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_radiation_therapy_prescription_date', display_name: 'Radiation therapy prescription date', abstractor_object_type: date_object_type, preferred_name: 'Radiation therapy prescription date')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'RadiationTherapyPrescription', abstractor_abstraction_schema: prescription_date_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name', abstractor_abstraction_source_type: source_type_nlp_suggestion, abstractor_rule_type: unknown_rule_type)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: location_group, display_order: 3)
  end

  def self.encounter_note
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    n_v_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    kps_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_karnofsky_performance_status', display_name: 'Karnofsky performance status', abstractor_object_type: list_object_type, preferred_name: 'Karnofsky performance status')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'kps')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'Karnofsky performance status (assessment scale)')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'Karnofsky index')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'EncounterNote', abstractor_abstraction_schema: kps_abstractor_abstraction_schema)
    abstractor_object_values = []
    abstractor_object_value = nil
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '100% - Normal; no complaints; no evidence of disease.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '100')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '100%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '90')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.90')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '90%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '80% - Normal activity with effort; some signs or symptoms of disease.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '80')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.80')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '80%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '70% - Cares for self; unable to carry on normal activity or to do active work.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '70')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.70')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '70%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '60% - Requires occasional assistance, but is able to care for most of his personal needs.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '60')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.60')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '60%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '50% - Requires considerable assistance and frequent medical care.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '50')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.50')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '50%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '40% - Disabled; requires special care and assistance.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '40')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.40')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '40%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '30% - Severely disabled; hospital admission is indicated although death not imminent.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '30')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.30')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '30%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '20% - Very sick; hospital admission necessary; active supportive treatment necessary.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '20')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.20')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '20%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '10% - Moribund; fatal processes progressing rapidly.')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '10')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '.10')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '10%')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: '0% - Dead')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '0')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: '0% ')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: n_v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    date_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_DATE).first
    custom_suggestion_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom suggestion').first
    kps_date_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_karnofsky_performance_status_date', display_name: 'Karnofsky performance status date', abstractor_object_type: date_object_type, preferred_name: 'Karnofsky performance status date')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'EncounterNote', abstractor_abstraction_schema: kps_date_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', custom_method: 'encounter_date', abstractor_abstraction_source_type: custom_suggestion_source_type)

    custom_suggestion_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom suggestion').first
    custom_suggestion_without_text_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_custom_suggestion_without_text', display_name: 'Has custom suggestion without text', abstractor_object_type: date_object_type, preferred_name: 'Has custom suggestion without text')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'EncounterNote', abstractor_abstraction_schema: custom_suggestion_without_text_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, custom_method: 'encounter_date_without_text', abstractor_abstraction_source_type: custom_suggestion_source_type)
  end

  def self.pathology_case
    dynamic_list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_DYNAMIC_LIST).first
    nlp_suggestion_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    unknown_rule_type = Abstractor::AbstractorRuleType.where(name: 'unknown').first

    surgery_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_surgery', display_name: 'Surgery', abstractor_object_type: dynamic_list_object_type, preferred_name: 'Surgery')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'PathologyCase', abstractor_abstraction_schema: surgery_abstraction_schema, dynamic_list_method: 'patient_surgeries')
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_abstraction_source_type: nlp_suggestion_source_type, abstractor_rule_type: unknown_rule_type)
  end

  def self.surgery
    indirect_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'indirect').first
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    value_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    surgery_anatomical_location_group  = Abstractor::AbstractorSubjectGroup.create(name: 'Surgery Anatomical Location')

    anatomical_location_abstractor_abstraction_schema = Setup.abstractor_abstraction_schema_anatomical_location
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Surgery', abstractor_abstraction_schema: anatomical_location_abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'surgical_procedure_notes', abstractor_rule_type: value_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: surgery_anatomical_location_group, display_order: 1)

    imaging_confirmed_extent_of_resection_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_imaging_confirmed_extent_of_resection', display_name: 'Extent of resection', abstractor_object_type: list_object_type, preferred_name: 'Extent of resection')
    abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Gross total resection')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: imaging_confirmed_extent_of_resection_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Subtotal resection')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: imaging_confirmed_extent_of_resection_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Surgery', abstractor_abstraction_schema: imaging_confirmed_extent_of_resection_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, abstractor_abstraction_source_type: indirect_source_type, from_method: 'patient_imaging_exams')
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, abstractor_abstraction_source_type: indirect_source_type, from_method: 'patient_surgical_procedure_reports')
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: surgery_anatomical_location_group, display_order: 2)
  end

  def self.imaging_exam
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    n_v_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first

    moomin_major_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_major_moomin_character', display_name: 'Favorite major Moomin character', abstractor_object_type: list_object_type, preferred_name: 'Favorite major Moomin character')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: moomin_major_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
    abstractor_object_values = []
    abstractor_object_value = nil

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'moomin')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_major_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'moominpapa')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_major_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'little my')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_major_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    dat_group  = Abstractor::AbstractorSubjectGroup.create(name: 'Dopamine Transporter Level')
    dat_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_dopamine_transporter_level', display_name: 'Dopamine transporter level', abstractor_object_type: list_object_type, preferred_name: 'Dopamine transporter level')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: dat_abstractor_abstraction_schema, value: 'DaT')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: dat_abstractor_abstraction_schema, value: 'DaT scan')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: dat_abstractor_abstraction_schema, value: 'DaTscan')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: dat_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: dat_group, display_order: 1)
    abstractor_object_values = []
    abstractor_object_value = nil
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Normal')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: dat_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Abnormal')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: dat_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: n_v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    anatomical_location_abstractor_abstraction_schema = Setup.abstractor_abstraction_schema_anatomical_location
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: anatomical_location_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: dat_group, display_order: 2)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    moomin_minor_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_minor_moomin_character', display_name: 'Favorite minor Moomin character', abstractor_object_type: list_object_type, preferred_name: 'Favorite minor Moomin character')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: moomin_minor_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
    abstractor_object_values = []
    abstractor_object_value = nil

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'fillyjonk')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_minor_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'hemulen')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_minor_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'the groke')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: moomin_minor_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)

    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    recist_response_group  = Abstractor::AbstractorSubjectGroup.create(name: 'RECIST response criteria')
    recist_response_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_recist_response_criteria', display_name: 'RECIST response criteria', abstractor_object_type: list_object_type, preferred_name: 'RECIST response criteria')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: recist_response_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: recist_response_group, display_order: 1)
    abstractor_object_values = []
    abstractor_object_value = nil
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'CR (complete response) = disappearance of all target lesions')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'CR')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'complete response')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: recist_response_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'PR (partial response) = 30% decrease in the sum of the longest diameter of target lesions')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'PR')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'partial response')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: recist_response_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'PD (progressive disease) = 20% increase in the sum of the longest diameter of target lesions')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'PD')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'progressive disease')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: recist_response_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'SD (stable disease) = small changes that do not meet above criteria')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'PD')
    abstractor_object_value.abstractor_object_value_variants << Abstractor::AbstractorObjectValueVariant.create(value: 'progressive disease')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: recist_response_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: anatomical_location_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: recist_response_group, display_order: 2)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)

    diagnosis_subject_group = Abstractor::AbstractorSubjectGroup.create(name: 'Diagnosis')
    diagnosis_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_diagnosis', display_name: 'Diagnosis', abstractor_object_type: list_object_type, preferred_name: 'Diagnosis')
    diagnosis_duration_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_diagnosis_duration', display_name: 'Duration', abstractor_object_type: list_object_type, preferred_name: 'Duration')

    ['Tremor', 'PD', 'Ataxia'].each do |diagnosis|
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: diagnosis)
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: diagnosis_abstraction_schema, abstractor_object_value: abstractor_object_value)
    end

    abstractor_section_type_custom = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_CUSTOM).first
    abstractor_section = Abstractor::AbstractorSection.create(abstractor_section_type: abstractor_section_type_custom, source_type: 'ImagingExam', source_method: 'note_text', name: 'favorite moomin', custom_regular_expression: "(?<=^|[\r\n])([A-Z][^delimiter]*)delimiter([^\r\n]*(?:[\r\n]+(?![A-Z].*delimiter).*)*)", delimiter: ':')

    ['2008', '2009', '2010'].each do |duration|
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: duration)
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: diagnosis_duration_abstraction_schema, abstractor_object_value: abstractor_object_value)
    end

    [1,2].each do |namespace_id|
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: diagnosis_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: namespace_id)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
      Abstractor::AbstractorAbstractionSource.create!(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion, section_name: 'favorite moomin')
      Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: diagnosis_subject_group, display_order: 1)

      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: diagnosis_duration_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: namespace_id)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
      Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject,abstractor_subject_group: diagnosis_subject_group, display_order: 2)
    end

    scoring_subject_group = Abstractor::AbstractorSubjectGroup.create(name: 'Scores', cardinality: 2)
    score_1_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_score_1', display_name: 'Score 1', abstractor_object_type: list_object_type, preferred_name: 'Score 1')
    score_2_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_score_2', display_name: 'Score 2', abstractor_object_type: list_object_type, preferred_name: 'Score 2')

    (1..3).each do |score|
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: score)
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: score_1_abstraction_schema, abstractor_object_value: abstractor_object_value)
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: score_2_abstraction_schema, abstractor_object_value: abstractor_object_value)
    end

    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: score_1_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 3)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: scoring_subject_group, display_order: 1)

    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: score_2_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 3)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: scoring_subject_group, display_order: 2)

    motor_ros_subject_group = Abstractor::AbstractorSubjectGroup.create(name: 'Motor ROS', cardinality: 1)
    falls_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_falls', display_name: 'Falls', abstractor_object_type: list_object_type, preferred_name: 'Falls')
    freezing_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_freezing', display_name: 'Freezing', abstractor_object_type: list_object_type, preferred_name: 'Freezing')

    ['yes', 'no'].each do |value|
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: value)
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: falls_abstraction_schema, abstractor_object_value: abstractor_object_value)
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: freezing_abstraction_schema, abstractor_object_value: abstractor_object_value)
    end

    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: falls_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 3)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: motor_ros_subject_group, display_order: 1)

    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'ImagingExam', abstractor_abstraction_schema: freezing_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 3)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    Abstractor::AbstractorSubjectGroupMember.create(abstractor_subject: abstractor_subject, abstractor_subject_group: motor_ros_subject_group, display_order: 2)
  end
end
