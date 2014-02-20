module Abstractor
  module Methods
    module Models
      module SuggestionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstraction_source
          base.send :belongs_to, :suggestion

          base.send :attr_accessible, :abstraction_source, :abstractor_abstraction_source_id, :suggestion, :abstractor_suggestion_id, :source_id, :source_type, :source_method, :match_value, :deleted_at
        end
      end
    end
  end
end
