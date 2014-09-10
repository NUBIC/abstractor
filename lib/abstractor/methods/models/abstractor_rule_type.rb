module Abstractor
  module Methods
    module Models
      module AbstractorRuleType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_abstraction_sources

          # base.send :attr_accessible, :deleted_at, :description, :name, :abstractor_subjects
        end
      end
    end
  end
end

