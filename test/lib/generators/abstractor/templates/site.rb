class Site < ActiveRecord::Base
  CENTRAL_NERVOUS_SYSTEM = 'central nervous system'
  has_and_belongs_to_many :site_categories

  scope :in_categories, lambda { |*categories| joins(:site_categories).where('synonym = false AND level = 4 AND site_categories_sites.site_category_id in (?)', normalize_category_ids(categories)) }
  scope :not_in_categories, lambda { |*categories| where("synonym = false AND level = 4 AND NOT EXISTS (SELECT 1 FROM site_categories_sites WHERE sites.id = site_categories_sites.site_id  AND site_categories_sites.site_category_id in(:categories))", { :categories => normalize_category_ids(categories) }) }

  def synonyms
    unless synonym
      Site.where(:icdo3_code => icdo3_code, :synonym => true)
    end
  end

  def preferred_term
    if synonym
      Site.where(:icdo3_code => icdo3_code, :synonym => false).first
    else
      self
    end
  end

  def self.distinct_anatomical_locations
    Site.in_categories('central nervous system').order(:name).map { |s| {:name => s.name, :search_value => s.name } }
  end

  def self.distinct_anatomical_locations_of_primary
    Site.not_in_categories('central nervous system').order(:name).map { |s| {:name => s.name, :search_value => s.name } }
  end

  def self.distinct_icdo3_anatomical_locations
    Site.in_categories('central nervous system').order(:name).map { |s| {:name => s.name, :search_value => s.icdo3_code } }
  end

  def self.lateralities
    ['bilateral', 'left', 'right', 'not applicable',  'unknown'].map { |l| {:name => l, :search_value => l } }
  end

  private

  def self.normalize_category_ids(categories)
    ids =  categories.select{ |c| c.is_a?(Integer) }
    category_names = categories.select{ |c| c.is_a?(String) }
    ids.concat(SiteCategory.all(:conditions => { :name => category_names }).map(&:id))
    ids.uniq
  end
end