module Abstractor
  module CustomNlpProvider
    ##
    # Determines the suggestion endpoint for the passed in custom NLP provider.
    #
    # The endpoint is assumed to be configured in config/abstractor/custom_nlp_providers.yml.
    # A template configratuon file can be generated in the host application by
    # calling the rake task abstractor:custom_nlp_provider.
    # @param [String] custom_nlp_provider The name of the custom NLP provider whose endpoint should be determined.
    # @return [String] The endpoint.
    def self.determine_suggestion_endpoint(custom_nlp_provider)
      suggestion_endpoint = YAML.load_file("#{Rails.root}/config/abstractor/custom_nlp_providers.yml")[custom_nlp_provider]['suggestion_endpoint'][Rails.env]
    end

    ##
    # Formats the object values and object value variants for the passed in Abstractor::AbstractorSubject.
    #
    # Preperation for submision to a custom NLP provider endpoint.
    #
    # @example Example of body prepared by Abstractor to submit to an custom NLP provider
    #   {
    #     "abstractor_abstraction_schema_id":1,
    #     "abstractor_abstraction_id":1,
    #     "abstractor_abstraction_source_id":1,
    #     "source_type":  "PathologyCase",
    #     "source_method": "note_text",
    #     "text": "The patient has a diagnosis of glioblastoma.  GBM does not have a good prognosis.  But I can't rule out meningioma.",
    #     "object_values": [
    #       { "value": "glioblastoma, nos",
    #         "object_value_variants":[
    #           { "value": "glioblastoma" },
    #           { "value": "gbm" },
    #           { "value": "spongioblastoma multiforme"}
    #         ]
    #       },
    #       { "value": "meningioma, nos",
    #         "object_value_variants":[
    #           { "value": "meningioma" },
    #           { "value": "leptomeningioma" },
    #           { "value": "meningeal fibroblastoma" }
    #         ]
    #       }
    #     ]
    #   }
    #
    #
    # @param [Abstractor::AbstractorSubject] abstractor_subject The abstractor subject having the desired object values.
    # @return [Hash]
    def self.abstractor_object_values(abstractor_subject)
      object_values = []
      abstractor_subject.abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
        object_value = {}
        object_value[:value] = abstractor_object_value.value
        object_value[:object_value_variants] = []
        abstractor_object_value.abstractor_object_value_variants.each do |abstractor_object_value_variant|
          object_value[:object_value_variants] << { value: abstractor_object_value_variant.value }
        end
        object_values << object_value
      end
      object_values
    end

    ##
    # Formats the JSON body in preparation for submision to a custom NLP provider endpoint.
    #
    # @example Example of body prepared by Abstractor to submit to an custom NLP provider
    #   {
    #     "abstractor_abstraction_schema_id":1,
    #     "abstractor_abstraction_id":1,
    #     "abstractor_abstraction_source_id":1,
    #     "source_type":  "PathologyCase",
    #     "source_method": "note_text",
    #     "text": "The patient has a diagnosis of glioblastoma.  GBM does not have a good prognosis.  But I can't rule out meningioma.",
    #     "object_values": [
    #       { "value": "glioblastoma, nos",
    #         "object_value_variants":[
    #           { "value": "glioblastoma" },
    #           { "value": "gbm" },
    #           { "value": "spongioblastoma multiforme"}
    #         ]
    #       },
    #       { "value": "meningioma, nos",
    #         "object_value_variants":[
    #           { "value": "meningioma" },
    #           { "value": "leptomeningioma" },
    #           { "value": "meningeal fibroblastoma" }
    #         ]
    #       }
    #     ]
    #   }
    #
    #
    # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The abstractor abstraction to be formated for submission to a custom nlp provider endpoint.
    # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The abstractor abstraction source to be formated for submission to a custom nlp provider endpoint.
    # @param [String] abstractor_text The text be formated for submission to a custom nlp provider endpoint.
    # @param [Hash] source The hash of values representing the source for submission to a custom nlp provider endpoint.
    # @return [Hash] The formatted body.
    def self.format_body_for_suggestion_endpoint(abstractor_abstraction, abstractor_abstraction_source, abstractor_text, source)
      object_values = CustomNlpProvider.abstractor_object_values(abstractor_abstraction.abstractor_subject)
      {
        abstractor_abstraction_schema_id: abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.id,
        abstractor_abstraction_id: abstractor_abstraction.id,
        abstractor_abstraction_source_id: abstractor_abstraction_source.id,
        source_id: source[:source_id],
        source_type: source[:source_type].to_s,
        source_method: source[:source_method],
        text: abstractor_text,
        object_values: object_values
      }
    end
  end
end