module Abstractor
  module Methods
    module Models
      module AbstractorSuggestionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_source
          base.send :belongs_to, :abstractor_suggestion
          base.send :has_many,   :abstractor_suggestion_source_ranges, dependent: :destroy

          # base.send :attr_accessible, :abstractor_abstraction_source, :abstractor_abstraction_source_id, :abstractor_suggestion, :abstractor_suggestion_id, :source_id, :source_type, :source_method, :match_value, :deleted_at, :sentence_match_value, :custom_method, :custom_explanation
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def detect_abstractor_suggestion_source_range(begin_position, end_position)
            abstractor_suggestion_source_ranges.where(begin_position: begin_position, end_position: end_position).first
          end
        end
      end
    end
  end
end
