module Abstractor
  module Methods
    module Models
      module AbstractorSubject
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_rule_type
          base.send :belongs_to, :abstractor_abstraction_schema

          base.send :has_one, :abstractor_subject_group_member
          base.send :has_one, :abstractor_subject_group, :through => :abstractor_subject_group_member

          base.send :has_many, :abstractor_abstractions
          base.send :has_many, :abstractor_abstraction_sources

          base.send :has_many, :object_relations,   :class_name => "Abstractor::AbstractorSubjectRelation", :foreign_key => "object_id"
          base.send :has_many, :subject_relations,  :class_name => "Abstractor::AbstractorSubjectRelation", :foreign_key => "subject_id"


          base.send :attr_accessible, :abstractor_abstraction_schema, :abstractor_abstraction_schema_id, :abstractor_rule_type, :abstractor_rule_type_id, :subject_type
        end

        # Instance Methods
        def abstract(about)
          abstractor_abstraction = about.find_or_create_abstractor_abstraction(abstractor_abstraction_schema, self)
          case abstractor_rule_type.name
          when 'name/value'
            abstract_name_value(about, abstractor_abstraction)
          when 'value'
            abstract_value(about, abstractor_abstraction)
          when 'unknown'
            abstract_unknown(about, abstractor_abstraction)
          end
        end

        def abstract_unknown(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end
        end

        def abstract_value(about, abstractor_abstraction)
          abstract_sentential_value(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end
        end

        def abstract_sentential_value(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            abstractor_text = about.send(abstractor_abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)
            abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
              abstractor_object_value.object_variants.each do |object_variant|
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
                        suggest(abstractor_abstraction, abstractor_abstraction_source, sentence[:sentence], about.id, subject_type, abstractor_abstraction_source.from_method, abstractor_object_value, nil, nil)
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def abstract_name_value(about, abstractor_abstraction)
          abstract_canonical_name_value(about, abstractor_abstraction)
          abstract_sentential_name_value(about, abstractor_abstraction)
          create_unknown_abstractor_suggestion_name_only(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
          end
        end

        def abstract_canonical_name_value(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            abstractor_text = about.send(abstractor_abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)
            abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
              abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
                abstractor_object_value.object_variants.each do |object_variant|
                  match_value = "#{Regexp.escape(predicate_variant)}:\s*#{Regexp.escape(object_variant)}"
                  matches = parser.scan(match_value, word_boundary: true).uniq
                  matches.each do |match|
                    suggest(abstractor_abstraction, abstractor_abstraction_source, match, about.id, subject_type, abstractor_abstraction_source.from_method, abstractor_object_value, nil, nil)
                  end

                  match_value = "#{Regexp.escape(predicate_variant)}#{Regexp.escape(object_variant)}"
                  matches = parser.scan(match_value, word_boundary: true).uniq
                  matches.each do |match|
                    suggest(abstractor_abstraction, abstractor_abstraction_source, match, about.id, subject_type, abstractor_abstraction_source.from_method, abstractor_object_value, nil, nil)
                  end
                end
              end
            end
          end
        end

        def abstract_sentential_name_value(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            abstractor_text = about.send(abstractor_abstraction_source.from_method)
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
                            suggest(abstractor_abstraction, abstractor_abstraction_source, sentence[:sentence], about.id, subject_type, abstractor_abstraction_source.from_method, abstractor_object_value, nil, nil)
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

        def suggest(abstractor_abstraction, abstractor_abstraction_source, match_value, source_id, source_type, source_method, abstractor_object_value, unknown, not_applicable)
          match_value.strip! unless match_value.nil?
          abstractor_suggestion = abstractor_abstraction.detect_abstractor_suggestion(abstractor_object_value.value) unless abstractor_object_value.nil?
          if !abstractor_suggestion
            abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first
            abstractor_suggestion = Abstractor::AbstractorSuggestion.create(
                                                                abstractor_abstraction: abstractor_abstraction,
                                                                abstractor_suggestion_status: abstractor_suggestion_status_needs_review,
                                                                suggested_value: abstractor_object_value.try(:value),
                                                                unknown: unknown,
                                                                not_applicable: not_applicable
                                                                )
            abstractor_suggestion.abstractor_suggestion_object_value = Abstractor::AbstractorSuggestionObjectValue.new(abstractor_object_value: abstractor_object_value)
          end

          abstractor_suggestion_source = abstractor_suggestion.detect_abstractor_suggestion_source(abstractor_abstraction_source, match_value, source_id, source_type)
          if !abstractor_suggestion_source
            Abstractor::AbstractorSuggestionSource.create(
                                              abstractor_abstraction_source: abstractor_abstraction_source,
                                              abstractor_suggestion: abstractor_suggestion,
                                              match_value: match_value,
                                              source_id: source_id,
                                              source_type: source_type,
                                              source_method: source_method
                                             )
          end
          abstractor_suggestion
        end

        def create_unknown_abstractor_suggestion_name_only(about, abstractor_abstraction)
          abstractor_abstraction_sources.each do |abstractor_abstraction_source|
            abstractor_text = about.send(abstractor_abstraction_source.from_method)
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
                        suggest(abstractor_abstraction, abstractor_abstraction_source, predicate_variant.downcase, about.id, subject_type, abstractor_abstraction_source.from_method, nil, true, nil)
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
          if abstractor_abstraction.abstractor_suggestions(true).empty?
            suggest(abstractor_abstraction, abstractor_abstraction_source, nil, about.id, subject_type, abstractor_abstraction_source.from_method, nil, true, nil)
          end
        end

        def groupable?
          !abstractor_subject_group_member.nil?
        end
      end
    end
  end
end