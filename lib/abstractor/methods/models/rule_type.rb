module Abstractor
  module Methods
    module Models
      module RuleType
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :subjects

          # base.send :attr_accessible :deleted_at, :description, :name
        end
      end
    end
  end
end

