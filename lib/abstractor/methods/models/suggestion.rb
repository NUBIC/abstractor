module Abstractor
  module Methods
    module Models
      module Suggestion
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstraction
          base.send :belongs_to, :suggestion_status

          base.send :has_one, :suggestion_object_value
          base.send :has_one, :object_value, :through => :suggestion_object_value

          base.send :has_many, :suggestion_sources

          base.send :attr_accessible, :abstraction, :abstractor_abstraction_id, :suggestion_sources, :abstractor_suggestion_source_id, :suggestion_status, :abstractor_suggestion_status_id, :suggested_value, :deleted_at, :unknown, :not_applicable

          # Hooks
          base.send :after_save, :update_abstraction_value, :if => lambda {|suggestion| suggestion.suggestion_status_id_changed?}
          base.send :after_save, :update_siblings_status, :if => lambda {|suggestion| suggestion.suggestion_status_id_changed?}
        end

        # Instance Methods
        def update_abstraction_value
          if suggestion_status.accepted?
            abstraction.value                     = suggested_value
            abstraction.unknown                   = unknown
            abstraction.not_applicable            = not_applicable
            abstraction.save!
          elsif suggestion_status.needs_review?
            abstraction.value          = nil
            abstraction.unknown        = nil
            abstraction.not_applicable = nil
            abstraction.save!
          elsif suggestion_status.rejected?
            abstraction.value          = nil if abstraction.value == suggested_value
            abstraction.unknown        = nil if unknown && abstraction.unknown == unknown
            abstraction.not_applicable = nil if not_applicable && abstraction.not_applicable == not_applicable
            abstraction.save!
          end
        end

        def update_siblings_status
          rejected_status = Abstractor::SuggestionStatus.where(:name => 'Rejected').first
          needs_review_status = Abstractor::SuggestionStatus.where(:name => 'Needs review').first

          if suggestion_status.accepted?
            #reject sibling suggestions
            self.sibling_suggestions.each do |suggestion|
              suggestion.suggestion_status = rejected_status
              suggestion.save!
            end
          elsif suggestion_status.needs_review?
            #reset status on sibling suggestions
            self.sibling_suggestions.each do |suggestion|
              suggestion.suggestion_status = needs_review_status
              suggestion.save!
            end
          end
        end

        def display_value
          if unknown
            'unknown'
          elsif not_applicable
            'not applicable'
          else
            suggested_value
          end
        end

        def sibling_suggestions
          abstraction.suggestions.where('id != ?', id)
        end

        def detect_suggestion_source(abstraction_source, match_value, source_id, source_type)
          suggestion_source = suggestion_sources.detect do |suggestion_source|
            suggestion_source.abstraction_source == abstraction_source &&
            suggestion_source.match_value == match_value &&
            suggestion_source.source_id == source_id &&
            suggestion_source.source_type == source_type
          end
        end
      end
    end
  end
end