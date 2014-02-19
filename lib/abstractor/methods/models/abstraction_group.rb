module Abstractor
  module Methods
    module Models
      module AbstractionGroup
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :subject_group
          base.send :belongs_to, :subject, polymorphic: true

          base.send :has_many, :abstraction_group_members
          base.send :has_many, :abstractions, :through => :abstraction_group_members

          # base.send :attr_accessible, :subject_group, :subject_group_id, :deleted_at, :subject, :subject_type, :subject_id

          # Hooks
          base.send :after_commit, :update_abstraction_group_members, :on => :update, :if => Proc.new { |record| record.previous_changes.include?('deleted_at') }
        end

        # Instance Methods
        def removable?
          abstractions.map(&:suggestions).flatten.empty?
        end

        private
          def update_abstraction_group_members
            return unless deleted?
            abstraction_group_members.each do |gm|
              gm.soft_delete!
              gm.abstractor_abstraction.soft_delete!
            end
          end
      end
    end
  end
end

