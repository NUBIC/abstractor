module Abstractor
  module Methods
    module Models
      module AbstractorSuggestion
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction
          base.send :belongs_to, :abstractor_suggestion_status

          base.send :has_one, :abstractor_suggestion_object_value
          base.send :has_one, :abstractor_object_value, :through => :abstractor_suggestion_object_value

          base.send :has_many, :abstractor_suggestion_sources

          # base.send :attr_accessible, :abstractor_abstraction, :abstractor_abstraction_id, :abstractor_suggestion_sources, :abstractor_suggestion_source_id, :abstractor_suggestion_status, :abstractor_suggestion_status_id, :suggested_value, :deleted_at, :unknown, :not_applicable

          # Hooks
          base.send :after_save, :update_abstraction_value, :if => lambda {|abstractor_suggestion| abstractor_suggestion.abstractor_suggestion_status_id_changed?}
          base.send :after_save, :update_siblings_status, :if => lambda {|abstractor_suggestion| abstractor_suggestion.abstractor_suggestion_status_id_changed?}
        end

        # Instance Methods
        def update_abstraction_value
          if abstractor_suggestion_status.accepted?
            abstractor_abstraction.value                     = suggested_value
            abstractor_abstraction.unknown                   = unknown
            abstractor_abstraction.not_applicable            = not_applicable
            abstractor_abstraction.save!
          elsif abstractor_suggestion_status.needs_review?
            abstractor_abstraction.value          = nil
            abstractor_abstraction.unknown        = nil
            abstractor_abstraction.not_applicable = nil
            abstractor_abstraction.save!
          elsif abstractor_suggestion_status.rejected?
            abstractor_abstraction.value          = nil if abstractor_abstraction.value == suggested_value
            abstractor_abstraction.unknown        = nil if unknown && abstractor_abstraction.unknown == unknown
            abstractor_abstraction.not_applicable = nil if not_applicable && abstractor_abstraction.not_applicable == not_applicable
            abstractor_abstraction.save!
          end
        end

        def update_siblings_status
          rejected_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
          needs_review_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first

          if abstractor_suggestion_status.accepted?
            #reject sibling suggestions
            self.sibling_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.abstractor_suggestion_status = rejected_status
              abstractor_suggestion.save!
            end
          elsif abstractor_suggestion_status.needs_review?
            #reset status on sibling suggestions
            self.sibling_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.abstractor_suggestion_status = needs_review_status
              abstractor_suggestion.save!
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
          abstractor_abstraction.abstractor_suggestions.where('id != ?', id)
        end

        def detect_abstractor_suggestion_source(abstractor_abstraction_source, sentence_match_value, source_id, source_type, source_method, section_name)
          abstractor_suggestion_source = abstractor_suggestion_sources.detect do |abstractor_suggestion_source|
            abstractor_suggestion_source.abstractor_abstraction_source == abstractor_abstraction_source &&
            abstractor_suggestion_source.sentence_match_value == sentence_match_value &&
            abstractor_suggestion_source.source_id == source_id &&
            abstractor_suggestion_source.source_type == source_type &&
            abstractor_suggestion_source.source_method == source_method &&
            abstractor_suggestion_source.section_name == section_name
          end
        end
      end
    end
  end
end