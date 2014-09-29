module Abstractor
  module Methods
    module Models
      module AbstractorSuggestionStatus
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_suggestions

          # base.send :attr_accessible, :deleted_at, :name
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