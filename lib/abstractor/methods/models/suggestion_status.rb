module Abstractor
  module Methods
    module Models
      module SuggestionStatus
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :suggestions

          # base.send :attr_accessible :deleted_at, :name
        end

        # Instance Methods
        def needs_review?
          name == 'Needs review'
        end

        def accepted?
          name == 'Accepted'
        end

        def rejected?
          name == 'Rejected'
        end
      end
    end
  end
end