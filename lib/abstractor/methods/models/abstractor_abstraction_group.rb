module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionGroup
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_subject_group
          base.send :belongs_to, :about, polymorphic: true

          base.send :has_many, :abstractor_abstraction_group_members
          base.send :has_many, :abstractor_abstractions, :through => :abstractor_abstraction_group_members

          base.send :attr_accessible, :abstractor_subject_group, :abstractor_subject_group_id, :deleted_at, :about, :about_type, :about_id

          # Hooks
          base.send :after_commit, :update_abstractor_abstraction_group_members, :on => :update, :if => Proc.new { |record| record.previous_changes.include?('deleted_at') }
        end

        ##
        # Determines if the group can be removed.
        #
        # @return [Boolean]
        def removable?
          abstractor_abstractions.map(&:abstractor_suggestions).flatten.empty?
        end

        ##
        # Updates all abstractor abstractions in a group to 'not applicable' or 'unknown'.
        #
        # @param [Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN, Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE] abstraction_other_value_type contorls whether to update all abstractor abstractions in the group to 'unknown' or 'not applicable'
        # @return [void]
        def update_abstractor_abstraction_other_value(abstraction_other_value_type)
          raise(ArgumentError, "abstraction_value_type argument invalid") unless Abstractor::Enum::ABSTRACTION_OTHER_VALUE_TYPES.include?(abstraction_other_value_type)

          rejected_status = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first
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
                  abstractor_suggestion.abstractor_suggestion_status = rejected_status
                  abstractor_suggestion.save!
                end
                abstractor_abstraction.value = nil
                abstractor_abstraction.unknown = unknown
                abstractor_abstraction.not_applicable = not_applicable
                abstractor_abstraction.save!
              end
            end
          end
        end

        private
          def update_abstractor_abstraction_group_members
            return unless deleted?
            abstractor_abstraction_group_members.each do |gm|
              gm.soft_delete!
              gm.abstractor_abstraction.soft_delete!
            end
          end
      end
    end
  end
end
