module Abstractor
  module Methods
    module Models
      module Abstraction
        def self.included(base)
          base.send :include, SoftDelete
          base.send :has_paper_trail

          # Associations
          base.send :belongs_to, :abstractor_subject, class_name: 'Abstractor::Subject', foreign_key: :abstractor_subject_id

          base.send :has_many, :suggestions
          base.send :has_many, :abstraction_sources, :through => :abstractor_suggestions

          base.send :has_one, :abstraction_group_member
          base.send :has_one, :abstraction_group, :through => :abstraction_group_member
          base.send :has_one, :abstraction_schema, :through => :abstractor_subject

          base.send :accepts_nested_attributes_for, :suggestions

          base.send :belongs_to, :subject, polymorphic: true

          base.send :attr_accessible, :subject, :abstractor_subject, :abstractor_subject_id, :value, :subject_id, :unknown, :not_applicable, :deleted_at

          # Hooks
          base.send :after_save, :review_matching_suggestions#, :if => lambda {|abstractor_abstraction| abstractor_abstraction.value_changed?}
        end

        # Instance Methods
        def subject
          subject_model = subject.subject_type.safe_constantize
          if subject_model
            subject_model.find(subject_id)
          end
        end

        def review_matching_suggestions
          accepted_status = Abstractor::SuggestionStatus.where(:name => 'Accepted').first
          matching_suggestions.each do |suggestion|
            suggestion.suggestion_status = accepted_status
            suggestion.save!
          end
        end

        def matching_suggestions
          unknown_values        = unknown ? unknown : [unknown, nil]
          not_applicable_values = not_applicable ? not_applicable : [not_applicable, nil]
          suggested_values = value.blank? ? ['', nil] : value
          suggestions.where(unknown: unknown_values, not_applicable: not_applicable_values, suggested_value: suggested_values)
        end

        def display_value
          if unknown
            'unknown'
          elsif not_applicable
            'not applicable'
          elsif value.blank?
            '[Not set]'
          else
            value
          end
        end

        def detect_suggestion(suggested_value)
          suggestion = nil
          suggestion = suggestions(true).detect do |suggestion|
            suggestion.suggested_value == suggested_value
          end
        end
      end
    end
  end
end