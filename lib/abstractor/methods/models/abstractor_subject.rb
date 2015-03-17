require 'rest_client'
module Abstractor
  module Methods
    module Models
      module AbstractorSubject
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_abstraction_schema

          base.send :has_one, :abstractor_subject_group_member
          base.send :has_one, :abstractor_subject_group, :through => :abstractor_subject_group_member

          base.send :has_many, :abstractor_abstractions
          base.send :has_many, :abstractor_abstraction_sources

          base.send :has_many, :object_relations,   :class_name => "Abstractor::AbstractorSubjectRelation", :foreign_key => "object_id"
          base.send :has_many, :subject_relations,  :class_name => "Abstractor::AbstractorSubjectRelation", :foreign_key => "subject_id"


          # base.send :attr_accessible, :abstractor_abstraction_schema, :abstractor_abstraction_schema_id, :subject_type, :dynamic_list_method
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          ##
          # Creates or finds an instance of an Abstractor::AbstractorAbstraction.
          # The method will create instances of Abstractor::AbstractorSuggestion and
          # Abstractor::AbstractorSuggestionSource for the abstractable entity
          # passed via the about parameter.
          #
          # The method cycles through each Abstractor::AbstractorAbstractionSource setup
          # for the instance of the Abstractor::AbstractorSubject.
          # The Abstractor::AbstractorSubject#abstractor_abstraction_source_type
          # attribute determines the abstraction strategy:
          #
          # * 'nlp suggestion': creates instances of Abstractor::AbstractorSuggestion based on natural language processing (nlp) logic searching the text provided by the Abstractor::AbstractorSubject#from_methd attribute.
          # * 'custom suggestion': creates instances of Abstractor::AbstractorSuggestion based on custom logic delegated to the method configured in AbstractorAbstractionSource#custom_method.
          # * 'indirect': creates an instance of Abstractor::AbstractorIndirectSource wih null source_type, source_id, source_method attributes -- all waiting to be set upon selection of an indirect source.
          # * 'custom nlp suggestion': looks up a suggestion endpoint to submit text, object values and object value variants to an external, custom NLP provider for the delegation of suggestion generation.
          #
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @return [void]
          def abstract(about)
            abstractor_abstraction = about.find_or_create_abstractor_abstraction(abstractor_abstraction_schema, self)

            abstractor_abstraction_sources.each do |abstractor_abstraction_source|
              case abstractor_abstraction_source.abstractor_abstraction_source_type.name
              when 'nlp suggestion'
                abstract_nlp_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
              when 'custom suggestion'
                abstract_custom_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
              when 'indirect'
                abstract_indirect_source(about, abstractor_abstraction, abstractor_abstraction_source)
              when 'custom nlp suggestion'
                abstract_custom_nlp_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
              end
            end
          end

          ##
          # Creates an instance of Abstractor::AbstractorIndirectSource -- if one does not already exist --
          # for the abstractor_abstraction and abstraction_source parameters.
          # An 'indirect' Abstractor::AbstractorAbstractionSources give developers
          # the ability to define a pool of documents that are indrectly related to an
          # abstraction.  The developer is responsible for implementing a
          # method on the abstractable enttiy specified in Abstractor::AbstractorAbstractionSource#from_method.
          # The method should return a hash with the following keys populated:
          #
          # * [Array <ActiveRecord::Base>] :sources An array of active record objects that constitute the list of indirect sources.
          # * [Symbol] :source_id A method specifying the primary key of each member in sources.
          # * [Symbol] :source_method A method specifying the source text of each member in sources.
          #
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The instance of Abstractor::AbstractorAbstraction to insert an indirect source.
          # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The instance of the Abstractor::AbstractorAbstractionSource that provides the indirec source.
          # @return [void]
          def abstract_indirect_source(about, abstractor_abstraction, abstractor_abstraction_source)
            if !abstractor_abstraction.detect_abstractor_indirect_source(abstractor_abstraction_source)
              source = about.send(abstractor_abstraction_source.from_method)
              abstractor_abstraction.abstractor_indirect_sources.build(abstractor_abstraction_source: abstractor_abstraction_source, source_type: source[:source_type], source_method: source[:source_method])
              abstractor_abstraction.save!
            end
          end

          ##
          # Creates instances of Abstractor::AbstractorSuggestion and Abstractor::AbstractorSuggestionSource
          # based on natural languange processing (nlp).
          #
          # The Abstractor::AbstractorSubject#abstractor_rule_type attribute determines the nlp strategy to employ:
          #
          # * 'name/value': attempts to search for non-negated sentences mentioning of an Abstractor::AbstractorAbstractionSchema#predicate and an Abstractor::AbstractorObjectValue
          # * 'value': attempts to search for non-negated sentences mentioning an Abstractor::AbstractorObjectValue
          # * 'unknown': will automatically create an 'unknown' Abstractor::AbstractorSuggestion
          #
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The instance of Abstractor::AbstractorAbstraction to make suggestions against.
          # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The instance of the Abstractor::AbstractorAbstractionSource that provides the rule type and from method to make nlp suggestions.
          # @return [void]
          def abstract_nlp_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
            case abstractor_abstraction_source.abstractor_rule_type.name
            when 'name/value'
              abstract_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            when 'value'
              abstract_value(about, abstractor_abstraction, abstractor_abstraction_source)
            when 'unknown'
              abstract_unknown(about, abstractor_abstraction, abstractor_abstraction_source)
            end
          end

          # Creates instances of Abstractor::AbstractorSuggestion and Abstractor::AbstractorSuggestionSource
          # based on calling the method configured by the AbstractorAbstractionSource#custom_method attribute.
          # The method is called on the abstractable entity passed via the about parameter.
          #
          # Setting up an Abstractor::AbstractorSubject with an AbstractorAbstractionSource
          # with an AbstractorAbstractionSource#abstractor_abstraction_source_type attribute
          # set to 'custom suggestion' obligates the developer to implement an instance
          # method on the abstractable entitty to make suggestions as appropriate.
          # The 'custom suggestion' source type is intended to faciliate the
          # generation of suggestions in a customizable way.  The method implemented
          # by the developer should return an array of hashes, each has with 2 keys, like so
          #
          # [{ suggestion: 'a suggestion', explanation: 'why i made the suggestion}]
          #
          # The suggestion will be presented to the user as possible answer for the
          # abstraction.  The explanation will be displayed to the user to explain
          # how the sytem arrived at the suggestion.
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The instance of Abstractor::AbstractorAbstraction to make suggestions against.
          # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The instance of the Abstractor::AbstractorAbstractionSource that provides the custom method to invoke on the abstractable entity to make custom suggestions.
          # @return [void]
          def abstract_custom_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
            suggestions = about.send(abstractor_abstraction_source.custom_method, abstractor_abstraction)
            suggestions.each do |suggestion|
              suggest(abstractor_abstraction, abstractor_abstraction_source, nil, nil, about.id, about.class.to_s, abstractor_abstraction_source.from_method, abstractor_abstraction_source.section_name, suggestion[:suggestion], nil, nil, abstractor_abstraction_source.custom_method, suggestion[:explanation])
            end
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end

          # Looks up a suggestion endpoint to submit text to an external
          # custom NLP provider for the delegation of suggestion generation.
          #
          # The method will determine an endpoint by looking in
          # config/abstractor/custom_nlp_providers.yml based on the current environment
          # and the value of the AbstractorAbstractionSource#custom_nlp_provider attribute.
          #
          # A template configratuon file can be generated in the the host application by
          # calling the rake task abstractor:custom_nlp_provider.  The configuration
          # is expected to provide different endpoints per environment, per provider.
          # Abstractor will format a JSON body to post to the discovered endpoint.
          # The custom NLP provider will be expected to generate suggestions
          # and post them back to /abstractor_abstractions/:abstractor_abstraction_id/abstractor_suggestions/
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
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction The instance of Abstractor::AbstractorAbstraction to make suggestions against.
          # @param [Abstractor::AbstractorAbstractionSource] abstractor_abstraction_source The instance of the Abstractor::AbstractorAbstractionSource that provides the name of the custom NLP provider.
          # @return [void]
          def abstract_custom_nlp_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
            suggestion_endpoint = CustomNlpProvider.determine_suggestion_endpoint(abstractor_abstraction_source.custom_nlp_provider)
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              abstractor_text = Abstractor::AbstractorAbstractionSource.abstractor_text(source)
              body = Abstractor::CustomNlpProvider.format_body_for_suggestion_endpoint(abstractor_abstraction, abstractor_abstraction_source, abstractor_text, source)
              RestClient.post(suggestion_endpoint, body.to_json, content_type: :json)
            end
          end

          def abstract_unknown(about, abstractor_abstraction, abstractor_abstraction_source)
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end

          def abstract_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstract_sentential_value(about, abstractor_abstraction, abstractor_abstraction_source)
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end

          def abstract_sentential_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              abstractor_text = Abstractor::AbstractorAbstractionSource.abstractor_text(source)
              abstractor_object_value_ids = abstractor_abstraction_schema.abstractor_object_values.map(&:id)

              abstractor_object_values = []
              abstractor_object_value_variants = []
              target_abstractor_object_values =[]
              target_abstractor_object_value_variants = Abstractor::AbstractorObjectValueVariant.where("abstractor_object_value_id in (?)", abstractor_object_value_ids).to_a

              at = nil
              at = abstractor_text.downcase unless abstractor_text.blank?
              target_abstractor_object_value_variants.each do |abstractor_object_value_variant|
                re = Regexp.new('\b' + Regexp.escape(abstractor_object_value_variant.value.downcase) + '\b')
                if re =~ at
                  abstractor_object_value_variants << abstractor_object_value_variant
                  abstractor_object_values << abstractor_object_value_variant.abstractor_object_value
                end
              end

              target_abstractor_object_values = abstractor_abstraction_schema.abstractor_object_values
              target_abstractor_object_values = target_abstractor_object_values - abstractor_object_values

              target_abstractor_object_values.each do |abstractor_object_value|
                re = Regexp.new('\b' + Regexp.escape(abstractor_object_value.value.downcase) + '\b')
                if re =~ at
                  abstractor_object_values << abstractor_object_value
                end
              end

              parser = Abstractor::Parser.new(abstractor_text)
              abstractor_object_values.each do |abstractor_object_value|
                object_variants(abstractor_object_value, abstractor_object_value_variants).each do |object_variant|
                  ranges = parser.range_all(Regexp.escape(object_variant.downcase))
                  if ranges.any?
                    ranges.each do |range|
                      sentence = parser.find_sentence(range)
                      if sentence
                        scoped_sentence = Abstractor::NegationDetection.parse_negation_scope(sentence[:sentence])
                        reject = (
                                  Abstractor::NegationDetection.negated_match_value?(scoped_sentence[:scoped_sentence], object_variant) ||
                                  Abstractor::NegationDetection.manual_negated_match_value?(sentence[:sentence], object_variant)
                                )
                        if !reject
                          suggest(abstractor_abstraction, abstractor_abstraction_source, object_variant.downcase, sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], source[:section_name], abstractor_object_value, nil, nil, nil, nil)
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          def abstract_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstract_canonical_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstract_sentential_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            create_unknown_abstractor_suggestion_name_only(about, abstractor_abstraction, abstractor_abstraction_source)
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end

          def abstract_canonical_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              abstractor_text = Abstractor::AbstractorAbstractionSource.abstractor_text(source)
              parser = Abstractor::Parser.new(abstractor_text)
              abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
                abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
                  abstractor_object_value.object_variants.each do |object_variant|
                    match_value = "#{Regexp.escape(predicate_variant)}:\s*#{Regexp.escape(object_variant)}"
                    matches = parser.scan(match_value, word_boundary: true).uniq
                    matches.each do |match|
                      suggest(abstractor_abstraction, abstractor_abstraction_source, match, match, source[:source_id], source[:source_type].to_s, source[:source_method], source[:section_name],  abstractor_object_value, nil, nil, nil, nil)
                    end

                    match_value = "#{Regexp.escape(predicate_variant)}#{Regexp.escape(object_variant)}"
                    matches = parser.scan(match_value, word_boundary: true).uniq
                    matches.each do |match|
                      suggest(abstractor_abstraction, abstractor_abstraction_source, match, match, source[:source_id], source[:source_type].to_s, source[:source_method], source[:seciton_name], abstractor_object_value, nil, nil, nil, nil)
                    end
                  end
                end
              end
            end
          end

          def abstract_sentential_name_value(about, abstractor_abstraction, abstractor_abstraction_source)
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              abstractor_text = Abstractor::AbstractorAbstractionSource.abstractor_text(source)
              parser = Abstractor::Parser.new(abstractor_text)
              abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
                ranges = parser.range_all(Regexp.escape(predicate_variant))
                if ranges.any?
                  ranges.each do |range|
                    sentence = parser.find_sentence(range)
                    if sentence
                      abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
                        abstractor_object_value.object_variants.each do |object_variant|
                          match = parser.match_sentence(sentence[:sentence], Regexp.escape(object_variant))
                          if match
                            scoped_sentence = Abstractor::NegationDetection.parse_negation_scope(sentence[:sentence])
                            reject = (
                                       Abstractor::NegationDetection.negated_match_value?(scoped_sentence[:scoped_sentence], predicate_variant) ||
                                       Abstractor::NegationDetection.manual_negated_match_value?(sentence[:sentence], predicate_variant) ||
                                       Abstractor::NegationDetection.negated_match_value?(scoped_sentence[:scoped_sentence], object_variant) ||
                                       Abstractor::NegationDetection.manual_negated_match_value?(sentence[:sentence], object_variant)
                                     )
                            if !reject
                              suggest(abstractor_abstraction, abstractor_abstraction_source, sentence[:sentence], sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], source[:section_name], abstractor_object_value, nil, nil, nil, nil)
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          def suggest(abstractor_abstraction, abstractor_abstraction_source, match_value, sentence_match_value, source_id, source_type, source_method, section_name, suggested_value, unknown, not_applicable, custom_method, custom_explanation)
            match_value.strip! unless match_value.nil?
            sentence_match_value.strip! unless sentence_match_value.nil?
            if abstractor_object_value?(suggested_value)
              abstractor_object_value = suggested_value
              suggested_value = suggested_value.value
            end
            abstractor_suggestion = abstractor_abstraction.detect_abstractor_suggestion(suggested_value, unknown, not_applicable)
            if !abstractor_suggestion
              abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first
              abstractor_suggestion = Abstractor::AbstractorSuggestion.create(
                                                                  abstractor_abstraction: abstractor_abstraction,
                                                                  abstractor_suggestion_status: abstractor_suggestion_status_needs_review,
                                                                  suggested_value: suggested_value,
                                                                  unknown: unknown,
                                                                  not_applicable: not_applicable
                                                                  )

              abstractor_suggestion.abstractor_suggestion_object_value = Abstractor::AbstractorSuggestionObjectValue.new(abstractor_object_value: abstractor_object_value) if abstractor_object_value
            end

            abstractor_suggestion_source = abstractor_suggestion.detect_abstractor_suggestion_source(abstractor_abstraction_source, sentence_match_value, source_id, source_type, source_method, section_name)
            if !abstractor_suggestion_source
              Abstractor::AbstractorSuggestionSource.create(
                                                abstractor_abstraction_source: abstractor_abstraction_source,
                                                abstractor_suggestion: abstractor_suggestion,
                                                match_value: match_value,
                                                sentence_match_value: sentence_match_value,
                                                source_id: source_id,
                                                source_type: source_type,
                                                source_method: source_method,
                                                section_name: section_name,
                                                custom_method: custom_method,
                                                custom_explanation: custom_explanation
                                               )
            end
            abstractor_suggestion
          end

          def abstractor_object_value?(suggested_value)
            suggested_value.instance_of?(Abstractor::AbstractorObjectValue)
          end

          def create_unknown_abstractor_suggestion_name_only(about, abstractor_abstraction, abstractor_abstraction_source)
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              abstractor_text = Abstractor::AbstractorAbstractionSource.abstractor_text(source)
              parser = Abstractor::Parser.new(abstractor_text)
              #Create an 'unknown' suggestion based on match name only if we have not made a suggstion
              if abstractor_abstraction.abstractor_suggestions(true).empty?
                abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
                  ranges = parser.range_all(Regexp.escape(predicate_variant))
                  if ranges
                    ranges.each do |range|
                      sentence = parser.find_sentence(range)
                      if sentence
                        scoped_sentence = Abstractor::NegationDetection.parse_negation_scope(sentence[:sentence])
                        reject = (
                                  Abstractor::NegationDetection.negated_match_value?(scoped_sentence[:scoped_sentence], predicate_variant) ||
                                  Abstractor::NegationDetection.manual_negated_match_value?(sentence[:sentence], predicate_variant)
                                )
                        if !reject
                          suggest(abstractor_abstraction, abstractor_abstraction_source, predicate_variant.downcase, sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], source[:section_name],  nil, true, nil, nil, nil)
                        end
                      end
                    end
                  end
                end
              end
            end
          end

          def create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
            #Create an 'unknown' suggestion based on matching nothing only if we have not made a suggstion
            abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
              if abstractor_abstraction.abstractor_suggestions(true).select { |abstractor_suggestion| abstractor_suggestion.unknown != true }.empty?
                suggest(abstractor_abstraction, abstractor_abstraction_source, nil, nil, source[:source_id], source[:source_type].to_s, source[:source_method],source[:section_name],  nil, true, nil, nil, nil)
              end
            end
          end

          def groupable?
            !abstractor_subject_group_member.nil?
          end

          private

            def object_variants(abstractor_object_value, abstractor_object_value_variants)
              aovv = abstractor_object_value_variants.select { |abstractor_object_value_variant| abstractor_object_value_variant.abstractor_object_value_id == abstractor_object_value.id }
              [abstractor_object_value.value].concat(aovv.map(&:value))
            end
        end
      end
    end
  end
end