module Abstractor
  module Methods
    module Models
      module AbstractorSectionType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_sections
        end
      end
    end
  end
end