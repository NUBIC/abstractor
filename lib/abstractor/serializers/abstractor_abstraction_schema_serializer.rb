require 'json'
module Abstractor
  module Serializers
    class AbstractorAbstractionSchemaSerializer
      def initialize(abstractor_abstraction_schema)
        @abstractor_abstraction_schema = abstractor_abstraction_schema
      end

      def as_json(options = {})
        {
          "predicate" => abstractor_abstraction_schema.predicate,
          "display_name" => abstractor_abstraction_schema.display_name,
          "abstractor_object_type" => abstractor_abstraction_schema.abstractor_object_type.value,
          "preferred_name" => abstractor_abstraction_schema.preferred_name,
          "predicate_variants" => abstractor_abstraction_schema.abstractor_abstraction_schema_predicate_variants.map { |abstractor_abstraction_schema_predicate_variant|  { 'value' => abstractor_abstraction_schema_predicate_variant.value  } },
          "object_values" => abstractor_abstraction_schema.abstractor_object_values.map do |abstractor_object_value|
            {
              'value' => abstractor_object_value.value,
              'properties' => abstractor_object_value.properties.nil? ? nil : JSON.parse(abstractor_object_value.properties),
              'object_value_variants' => abstractor_object_value.abstractor_object_value_variants.map { |abstractor_object_value_variant| { 'value' => abstractor_object_value_variant.value } }
            }
          end
        }
      end

      private

        attr_reader :abstractor_abstraction_schema
    end
  end
end