module Abstractor
  module Methods
    module Models
      module AbstractorSuggestionObjectValue
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_suggestion
          base.send :belongs_to, :abstractor_object_value

          # base.send :attr_accessible, :abstractor_suggestion, :abstractor_suggestion_id, :abstractor_object_value, :abstractor_object_value_id, :deleted_at
        end
      end
    end
  end
end