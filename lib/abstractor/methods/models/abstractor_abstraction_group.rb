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
          base.send :validate, :must_have_members

          base.send :after_commit, :update_abstractor_abstraction_group_members, :on => :update, :if => Proc.new { |record| record.previous_changes.include?('deleted_at') }

          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          ##
          # Determines if the group can be removed.
          #
          # @return [Boolean]
          def removable?
            !system_generated
          end

          def has_subtype?(s)
            subtype == s
          end

          private
            def update_abstractor_abstraction_group_members
              return unless deleted?
              abstractor_abstraction_group_members.each do |gm|
                gm.soft_delete!
                gm.abstractor_abstraction.soft_delete!
              end
            end

            def must_have_members
              if self.abstractor_abstraction_group_members.empty? || self.abstractor_abstraction_group_members.all? {|abstractor_abstraction_group_member| abstractor_abstraction_group_member.marked_for_destruction? }
                errors.add(:base, 'Must have at least one abstractor_abstraction_group_member')
              end
            end

            def validate_subject_group_cardinality
              return if self.abstractor_subject_group.cardinality.blank? || self.persisted?
              errors.add(:base,"Subject group reached maximum number of abstraction groups (#{abstractor_subject_group.cardinality})") if self.about.abstractor_subject_group_complete?(self.abstractor_subject_group_id)
            end
        end
      end
    end
  end
end
