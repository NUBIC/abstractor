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

          # base.send :attr_accessible, :abstractor_subject_group, :abstractor_subject_group_id, :deleted_at, :about, :about_type, :about_id

          # Hooks
          base.send :validate, :validate_subject_group_cardinality
          base.send :after_commit, :update_abstractor_abstraction_group_members, :on => :update, :if => Proc.new { |record| record.previous_changes.include?('deleted_at') }

          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          ##
          # Determines if the group can be removed.
          #
          # @return [Boolean]
          def removable?
            abstractor_abstractions.map(&:abstractor_suggestions).flatten.empty?
          end

          private
            def update_abstractor_abstraction_group_members
              return unless deleted?
              abstractor_abstraction_group_members.each do |gm|
                gm.soft_delete!
                gm.abstractor_abstraction.soft_delete!
              end
            end

            def validate_subject_group_cardinality
              return if self.abstractor_subject_group.cardinality.blank? || self.persisted?
              errors.add(:base,"Subject group reached maximum number of abstraction groups (#{abstractor_subject_group.cardinality})") if self.abstractor_subject_group.group_complete?
            end
        end
      end
    end
  end
end
