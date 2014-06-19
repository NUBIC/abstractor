module Abstractor
  module Methods
    module Models
      module AbstractorAbstraction
        def self.included(base)
          base.send :include, SoftDelete
          base.send :has_paper_trail

          # Associations
          base.send :belongs_to, :abstractor_subject

          base.send :has_many, :abstractor_suggestions
          base.send :has_many, :abstractor_abstraction_sources, :through => :abstractor_abstractor_suggestions

          base.send :has_one, :abstractor_abstraction_group_member
          base.send :has_one, :abstractor_abstraction_group, :through => :abstractor_abstraction_group_member
          base.send :has_one, :abstractor_abstraction_schema, :through => :abstractor_subject

          base.send :accepts_nested_attributes_for, :abstractor_suggestions

          base.send :belongs_to, :about, polymorphic: true

          base.send :attr_accessible, :about, :abstractor_subject, :abstractor_subject_id, :value, :about_type, :about_id, :unknown, :not_applicable, :deleted_at

          # Hooks
          base.send :after_save, :review_matching_suggestions#, :if => lambda {|abstractor_abstraction| abstractor_abstraction.value_changed?}

          base.send(:include, InstanceMethods)
          base.extend(ClassMethods)
        end

        module InstanceMethods
          def review_matching_suggestions
            accepted_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
            matching_abstractor_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.abstractor_suggestion_status = accepted_status
              abstractor_suggestion.save!
            end
          end

          def matching_abstractor_suggestions
            unknown_values        = unknown ? unknown : [unknown, nil]
            not_applicable_values = not_applicable ? not_applicable : [not_applicable, nil]
            suggested_values = value.blank? ? ['', nil] : value
            abstractor_suggestions.where(unknown: unknown_values, not_applicable: not_applicable_values, suggested_value: suggested_values)
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

          def detect_abstractor_suggestion(suggested_value)
            abstractor_suggestion = nil
            abstractor_suggestion = abstractor_suggestions(true).detect do |abstractor_suggestion|
              abstractor_suggestion.suggested_value == suggested_value
            end
          end

          def unreviewed?
            abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first
            abstractor_suggestions.any? { |abstractor_suggestion| abstractor_suggestion.abstractor_suggestion_status == abstractor_suggestion_status_needs_review }
          end
        end

        module ClassMethods
          ##
          # Updates all abstractor abstractions passed in to 'not applicable' or 'unknown'.
          #
          # @param [Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE] abstraction_other_value_type contorls whether to update all abstractor abstractions in the group to 'unknown' or 'not applicable'
          # @return [void]
          def update_abstractor_abstraction_other_value(abstractor_abstractions, abstraction_other_value_type)
            raise(ArgumentError, "abstraction_value_type argument invalid") unless Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPES.include?(abstraction_other_value_type)

            rejected_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
            accepted_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
            case abstraction_other_value_type
            when Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN
              unknown = true
              not_applicable = false
            when Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE
              unknown = false
              not_applicable = true
            end

            Abstractor::AbstractorAbstraction.transaction do
              if abstraction_other_value_type
                abstractor_abstractions.each do |abstractor_abstraction|
                  abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
                    if unknown && abstractor_suggestion.unknown
                      abstractor_suggestion.abstractor_suggestion_status = accepted_status
                      abstractor_suggestion.save!
                    else
                      set_abstractor_abstraction(abstractor_abstraction, unknown, not_applicable)
                      abstractor_suggestion.abstractor_suggestion_status = rejected_status
                      abstractor_suggestion.save!
                    end
                  end
                end
              end
            end
          end

          private
            def set_abstractor_abstraction(abstractor_abstraction, unknown, not_applicable)
              abstractor_abstraction.value = nil
              abstractor_abstraction.unknown = unknown
              abstractor_abstraction.not_applicable = not_applicable
              abstractor_abstraction.save!
            end
        end
      end
    end
  end
end