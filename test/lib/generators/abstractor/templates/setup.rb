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
    list_object_type = Abstractor::ObjectType.where(value: 'list').first
    v_rule = Abstractor::RuleType.where(name: 'value').first

    anatomical_location_abstraction_schema = Abstractor::AbstractionSchema.create(predicate: 'has_anatomical_location', display_name: 'Anatomical location', object_type: list_object_type, preferred_name: 'Anatomical location')
    Site.where(:synonym => false).each do |site|
      object_value = Abstractor::ObjectValue.create(:value => site.name)
      Abstractor::AbstractionSchemaObjectValue.create(:abstraction_schema => anatomical_location_abstraction_schema, :object_value => object_value)
      Site.where(:icdo3_code => site.icdo3_code, :synonym => true).each do |site_synonym|
        Abstractor::ObjectValueVariant.create(:object_value => object_value, :value => site_synonym.name)
      end
    end

    location_group  = Abstractor::SubjectGroup.create(:name => 'Anatomical Location')

    abstractor_subject = Abstractor::Subject.create(:subject_type => 'RadiationTherapyPrescription', :abstraction_schema => anatomical_location_abstraction_schema, :rule_type => v_rule)
    Abstractor::AbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name')
    Abstractor::SubjectGroupMember.create(:abstractor_subject => abstractor_subject, :subject_group => location_group, :display_order => 1)

    laterality_abstraction_schema = Abstractor::AbstractionSchema.create(:predicate => 'has_laterality', :display_name => 'Laterality', :object_type => list_object_type, preferred_name: 'Laterality')
    left_ov       = Abstractor::ObjectValue.create(:value => 'left')
    right_ov      = Abstractor::ObjectValue.create(:value => 'right')
    bilaterial_ov = Abstractor::ObjectValue.create(:value => 'bilaterial')

    laterals = [left_ov, right_ov, bilaterial_ov]

    laterals.each do |object_value|
      Abstractor::AbstractionSchemaObjectValue.create(:abstraction_schema => laterality_abstraction_schema, :object_value => object_value)
    end

    abstractor_subject = Abstractor::Subject.create(:subject_type => 'RadiationTherapyPrescription', :abstraction_schema => laterality_abstraction_schema, :rule_type => v_rule)
    Abstractor::AbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'site_name')
    Abstractor::SubjectGroupMember.create(:abstractor_subject => abstractor_subject, :subject_group => location_group, :display_order => 2)
  end

  def self.encounter_note
    list_object_type = Abstractor::ObjectType.where(value: 'list').first
    n_v_rule = Abstractor::RuleType.where(name: 'name/value').first
    kps_abstraction_schema = Abstractor::AbstractionSchema.create(predicate: 'has_karnofsky_performance_status', display_name: 'Karnofsky performance status', object_type: list_object_type, preferred_name: 'Karnofsky performance status')
    Abstractor::AbstractionSchemaPredicateVariant.create(abstraction_schema: kps_abstraction_schema, value: 'kps')
    Abstractor::AbstractionSchemaPredicateVariant.create(abstraction_schema: kps_abstraction_schema, value: 'Karnofsky performance status (assessment scale)')
    Abstractor::AbstractionSchemaPredicateVariant.create(abstraction_schema: kps_abstraction_schema, value: 'Karnofsky index')
    abstractor_subject = Abstractor::Subject.create(:subject_type => 'EncounterNote', :abstraction_schema => kps_abstraction_schema, :rule_type => n_v_rule)
    object_values = []
    object_value = nil
    object_values << object_value = Abstractor::ObjectValue.create(value: '100% - Normal; no complaints; no evidence of disease.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '100')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '100%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '90% - Able to carry on normal activity; minor signs or symptoms of disease.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '90')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.90')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '90%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '80% - Normal activity with effort; some signs or symptoms of disease.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '80')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.80')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '80%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '70% - Cares for self; unable to carry on normal activity or to do active work.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '70')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.70')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '70%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '60% - Requires occasional assistance, but is able to care for most of his personal needs.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '60')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.60')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '60%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '50% - Requires considerable assistance and frequent medical care.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '50')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.50')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '50%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '40% - Disabled; requires special care and assistance.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '40')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.40')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '40%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '30% - Severely disabled; hospital admission is indicated although death not imminent.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '30')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.30')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '30%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '20% - Very sick; hospital admission necessary; active supportive treatment necessary.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '20')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.20')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '20%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '10% - Moribund; fatal processes progressing rapidly.')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '10')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '.10')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '10%')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    object_values << object_value = Abstractor::ObjectValue.create(value: '0% - Dead')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '0')
    object_value.object_value_variants << Abstractor::ObjectValueVariant.create(value: '0% ')
    object_value.save
    Abstractor::AbstractionSchemaObjectValue.create(abstraction_schema: kps_abstraction_schema, object_value: object_value)
    Abstractor::AbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text')
  end
end