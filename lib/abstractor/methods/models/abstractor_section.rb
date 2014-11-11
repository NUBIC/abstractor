module Abstractor
  module Methods
    module Models
      module AbstractorSection
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_section_type
          base.send :has_many, :abstractor_section_name_variants
        end

        def prepare_section_name_variants
          section_name_variants.join('|')
        end

        def section_name_variants
          [name].concat(abstractor_section_name_variants.map(&:name))
        end
      end
    end
  end
end