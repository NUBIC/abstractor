module Abstractor
  module Methods
    module Models
      module AbstractorSuggestionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_source
          base.send :belongs_to, :abstractor_suggestion

          base.send :attr_accessible, :abstractor_abstraction_source, :abstractor_abstraction_source_id, :abstractor_suggestion, :abstractor_suggestion_id, :source_id, :source_type, :source_method, :match_value, :deleted_at, :sentence_match_value
        end
      end
    end
  end
end
