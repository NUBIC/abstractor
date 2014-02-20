module Abstractor
  module Methods
    module Models
      module SuggestionObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :suggestion
          base.send :belongs_to, :object_value

          base.send :attr_accessible, :suggestion, :abstractor_suggestion_id, :object_value, :abstractor_object_value_id, :deleted_at
        end
      end
    end
  end
end