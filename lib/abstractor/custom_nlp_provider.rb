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
      Abstractor::CustomNlpProvider.determine_endpoint(custom_nlp_provider, 'suggestion_endpoint')
    end

    def self.determine_schema_endpoint(custom_nlp_provider)
      Abstractor::CustomNlpProvider.determine_endpoint(custom_nlp_provider, 'schema_endpoint')
    end

    def self.determine_endpoint(custom_nlp_provider, endpoint)
      suggestion_endpoint = YAML.load_file("#{Rails.root}/config/abstractor/custom_nlp_providers.yml")[custom_nlp_provider][endpoint][Rails.env]
    end

    ##
    # Formats the JSON body in preparation for submision to a custom NLP provider endpoint.
    #
    # @example Example of body prepared by Abstractor to submit to an custom NLP provider
    #   {
    #     "abstractor_abstraction_schema_id":1,
    #     "abstractor_abstraction_schema_uri":"https://moomin.com/abstractor_abstraction_schemas/1",
    #     "abstractor_abstraction_id":1,
    #     "abstractor_abstraction_source_id":1,
    #     "source_type":  "PathologyCase",
    #     "source_method": "note_text",
    #     "text": "The patient has a diagnosis of glioblastoma.  GBM does not have a good prognosis.  But I can't rule out meningioma."
    #   }
    #
    #
    # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The abstractor abstraction to be formated for submission to a custom nlp provider endpoint.
    # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The abstractor abstraction source to be formated for submission to a custom nlp provider endpoint.
    # @param [String] abstractor_text The text be formated for submission to a custom nlp provider endpoint.
    # @param [Hash] source The hash of values representing the source for submission to a custom nlp provider endpoint.
    # @return [Hash] The formatted body.
    def self.format_body_for_suggestion_endpoint(abstractor_abstraction, abstractor_abstraction_source, abstractor_text, source)
      {
        abstractor_abstraction_schema_id: abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema.id,
        abstractor_abstraction_schema_uri: Abstractor::Engine.routes.url_helpers.abstractor_abstraction_schema_url(abstractor_abstraction.abstractor_subject.abstractor_abstraction_schema,  format: :json),
        abstractor_abstraction_abstractor_suggestions_uri: Abstractor::Engine.routes.url_helpers.abstractor_abstraction_abstractor_suggestions_url(abstractor_abstraction, format: :json),
        abstractor_abstraction_id: abstractor_abstraction.id,
        abstractor_abstraction_source_id: abstractor_abstraction_source.id,
        source_id: source[:source_id],
        source_type: source[:source_type].to_s,
        source_method: source[:source_method],
        text: abstractor_text
      }
    end

    ##
    # Formats the JSON body in preparation for submision to a custom NLP schema provider endpoint.
    #
    # @example Example of body prepared by Abstractor to submit to an custom NLP provider
    #   {
    #     "abstractor_abstraction_schema_id":1,
    #     "abstractor_abstraction_schema_uri":"https://moomin.com/abstractor_abstraction_schemas/1",
    #     "abstractor_abstraction_id":1,
    #     "abstractor_abstraction_source_id":1,
    #     "source_type":  "PathologyCase",
    #     "suggestions_uri": "https://moomin.com/abstractor_abstraction_schemas/",
    #     "text": "The patient has a diagnosis of glioblastoma.  GBM does not have a good prognosis.  But I can't rule out meningioma."
    #   }
    #
    #
    # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The abstractor abstraction to be formated for submission to a custom nlp provider endpoint.
    # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The abstractor abstraction source to be formated for submission to a custom nlp provider endpoint.
    # @param [String] abstractor_text The text be formated for submission to a custom nlp provider endpoint.
    # @param [Hash] source The hash of values representing the source for submission to a custom nlp provider endpoint.
    # @return [Hash] The formatted body.
    def self.format_body_for_abstraction_schema_endpoint(universe, universe_name_variants, about, abstractor_text)
      a = {
        universe_id:              universe.id,
        universe_name:            universe.name,
        universe_name_variants:   universe_name_variants << universe.name,
        about_type:               about.class.name,
        about_id:                 about.id,
        suggestions_uri:          Abstractor::Engine.routes.url_helpers.configure_and_store_abstractions_abstractor_abstraction_schema_sources_url(format: :json),
        text:                     abstractor_text
      }
      puts a
      a
    end
  end
end
