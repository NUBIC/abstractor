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
    sites = CSV.new(File.open('lib/setup/data/ICD-O-3_CSV-metadata/Topoenglish.csv'), :headers => true, :col_sep =>',', :return_headers => false)
    sites.each do |row|
      if Site.where(icdo3_code: row.to_hash['Kode'], name: row.to_hash['Title'].downcase).empty?
        Site.create!(:icdo3_code => row.to_hash['Kode'], :level => Setup.map_site_level(row.to_hash['Lvl']), :name => row.to_hash['Title'].downcase, :synonym => Setup.site_synonym?(row.to_hash['Lvl'])) if (row.to_hash['Lvl'] == '3' || row.to_hash['Lvl'] == '4' ||  row.to_hash['Lvl'] == 'incl')
      else
        puts 'little my says it already exists!'
      end
    end
  end

  def self.custom_site_synonyms
    site_synonyms = CSV.new(File.open('lib/setup/data/custom_site_synonyms.csv'), :headers => true, :col_sep =>',', :return_headers => false)
    site_synonyms.each do |row|
      if Site.where(:icdo3_code => row.to_hash['icdo3_code'], :level => 4, :name => row.to_hash['name'].downcase, :synonym => true).empty?
        Site.create!(:icdo3_code => row.to_hash['icdo3_code'], :level => 4, :name => row.to_hash['name'].downcase, :synonym => true)
      else
        puts 'little my says it already exists!'
      end
    end
  end

  def self.site_categories
    site_categories = CSV.new(File.open('lib/setup/data/site_site_categories.txt'), :headers => true, :col_sep =>"\t", :return_headers => false)
    site_categories.each do |row|
      site_category= SiteCategory.where(:name => row.to_hash['site_category']).first
      if site_category.blank?
        site_category = SiteCategory.create!(:name => row.to_hash['site_category'])
      end

      Site.where(:icdo3_code => row.to_hash['icdo3_code']).each do |site|
        site.site_categories << site_category unless site.site_categories.include?(site_category)
      end
    end
  end

  def self.laterality
    laterals = CSV.new(File.open('lib/setup/data/icdo3_sites_with_laterality.txt'), :headers => true, :col_sep =>"\t", :return_headers => false)
    laterals.each do |row|
      site = Site.where(:icdo3_code => row.to_hash['icdo3_code'], :synonym => false).first
      site.laterality = true
      site.save!
    end
  end

  def self.radiation_therapy_prescription
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    radio_button_list_object_type = Abstractor::AbstractorObjectType.where(value: 'radio button list').first

    v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first

    anatomical_location_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_anatomical_location', display_name: 'Anatomical location', abstractor_object_type: list_object_type, preferred_name: 'Anatomical location')
    Site.where(:synonym => false).each do |site|
      object_value = Abstractor::AbstractorObjectValue.create(:value => site.name)
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(:abstractor_abstraction_schema => anatomical_location_abstractor_abstraction_schema, :abstractor_object_value => object_value)
      Site.where(:icdo3_code => site.icdo3_code, :synonym => true).each do |site_synonym|
        Abstractor::AbstractorObjectValueVariant.create(:abstractor_object_value => object_value, :value => site_synonym.name)
      end
    end

    location_group  = Abstractor::AbstractorSubjectGroup.create(:name => 'Anatomical Location')

    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'RadiationTherapyPrescription', :abstractor_abstraction_schema => anatomical_location_abstractor_abstraction_schema, :abstractor_rule_type => v_rule)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name')
    Abstractor::AbstractorSubjectGroupMember.create(:abstractor_subject => abstractor_subject, :abstractor_subject_group => location_group, :display_order => 1)

    laterality_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(:predicate => 'has_laterality', :display_name => 'Laterality', :abstractor_object_type => radio_button_list_object_type, preferred_name: 'Laterality')
    left_ov       = Abstractor::AbstractorObjectValue.create(:value => 'left')
    right_ov      = Abstractor::AbstractorObjectValue.create(:value => 'right')
    bilateral_ov = Abstractor::AbstractorObjectValue.create(:value => 'bilateral')

    laterals = [left_ov, right_ov, bilateral_ov]

    laterals.each do |object_value|
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(:abstractor_abstraction_schema => laterality_abstractor_abstraction_schema, :abstractor_object_value => object_value)
    end

    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'RadiationTherapyPrescription', :abstractor_abstraction_schema => laterality_abstractor_abstraction_schema, :abstractor_rule_type => v_rule)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name')
    Abstractor::AbstractorSubjectGroupMember.create(:abstractor_subject => abstractor_subject, :abstractor_subject_group => location_group, :display_order => 2)

    date_object_type = Abstractor::AbstractorObjectType.where(value: 'date').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    prescription_date_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_radiation_therapy_prescription_date', display_name: 'Radiation therapy prescription date', abstractor_object_type: date_object_type, preferred_name: 'Radiation therapy prescription date')
    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'RadiationTherapyPrescription', :abstractor_abstraction_schema => prescription_date_abstractor_abstraction_schema, :abstractor_rule_type => unknown_rule)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name')
    Abstractor::AbstractorSubjectGroupMember.create(:abstractor_subject => abstractor_subject, :abstractor_subject_group => location_group, :display_order => 3)
  end

  def self.encounter_note
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    n_v_rule = Abstractor::AbstractorRuleType.where(name: 'name/value').first
    kps_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_karnofsky_performance_status', display_name: 'Karnofsky performance status', abstractor_object_type: list_object_type, preferred_name: 'Karnofsky performance status')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'kps')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'Karnofsky performance status (assessment scale)')
    Abstractor::AbstractorAbstractionSchemaPredicateVariant.create(abstractor_abstraction_schema: kps_abstractor_abstraction_schema, value: 'Karnofsky index')
    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'EncounterNote', :abstractor_abstraction_schema => kps_abstractor_abstraction_schema, :abstractor_rule_type => n_v_rule)
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
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text')

    date_object_type = Abstractor::AbstractorObjectType.where(value: 'date').first
    unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
    kps_date_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_karnofsky_performance_status_date', display_name: 'Karnofsky performance status date', abstractor_object_type: date_object_type, preferred_name: 'Karnofsky performance status date')
    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'EncounterNote', :abstractor_abstraction_schema => kps_date_abstractor_abstraction_schema, :abstractor_rule_type => unknown_rule)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text')
  end
end