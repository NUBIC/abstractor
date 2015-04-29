module Abstractor
  module Methods
    module Models
      module AbstractorSuggestionSourceRange
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_suggestion
        end
      end
    end
  end
end
