module Abstractor
  module Methods
    module Models
      module Subject
        def self.included(base)
          # base.send :include, NegationDetection
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :rule_type
          base.send :belongs_to, :abstraction_schema

          base.send :has_one, :subject_group_member, :foreign_key => "abstractor_subject_id"
          base.send :has_one, :subject_group, :through => :subject_group_member

          base.send :has_many, :abstractions
          base.send :has_many, :abstraction_sources, :foreign_key => "abstractor_subject_id"

          base.send :has_many, :object_relations,   :class_name => "Abstractor::SubjectRelation", :foreign_key => "object_id"
          base.send :has_many, :subject_relations,  :class_name => "Abstractor::SubjectRelation", :foreign_key => "subject_id"


          base.send :attr_accessible, :abstraction_schema, :abstractor_abstraction_schema_id, :rule_type, :abstractor_rule_type_id, :subject_type
        end

        # Instance Methods
        def abstract(subject)
          abstraction = subject.find_or_create_abstraction(abstraction_schema, self)
          case rule_type.name
          when 'name/value'
            abstract_name_value(subject, abstraction)
          when 'value'
            abstract_value(subject, abstraction)
          end
        end

        def abstract_value(subject, abstraction)
          abstract_sentential_value(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            create_unknown_suggestion(subject, abstraction, abstraction_source)
          end
        end

        def abstract_sentential_value(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            abstractor_text = subject.send(abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)
            abstraction_schema.object_values.each do |object_value|
              object_value.object_variants.each do |object_variant|
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
                        suggest(abstraction, abstraction_source, sentence[:sentence], subject.id, subject_type, abstraction_source.from_method, object_value, nil, nil)
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def abstract_name_value(subject, abstraction)
          abstract_canonical_name_value(subject, abstraction)
          abstract_sentential_name_value(subject, abstraction)
          create_unknown_suggestion_name_only(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            create_unknown_suggestion(subject, abstraction, abstraction_source)
          end
        end

        def abstract_canonical_name_value(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            abstractor_text = subject.send(abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)

            abstraction_schema.predicate_variants.each do |predicate_variant|
              abstraction_schema.object_values.each do |object_value|
                object_value.object_variants.each do |object_variant|
                  match_value = "#{Regexp.escape(predicate_variant)}:\s*#{Regexp.escape(object_variant)}"
                  matches = parser.scan(match_value, word_boundary: true).uniq
                  matches.each do |match|
                    suggest(abstraction, abstraction_source, match, subject.id, subject_type, abstraction_source.from_method, object_value, nil, nil)
                  end

                  match_value = "#{Regexp.escape(predicate_variant)}#{Regexp.escape(object_variant)}"
                  matches = parser.scan(match_value, word_boundary: true).uniq
                  matches.each do |match|
                    suggest(abstraction, abstraction_source, match, subject.id, subject_type, abstraction_source.from_method, object_value, nil, nil)
                  end
                end
              end
            end
          end
        end

        def abstract_sentential_name_value(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            abstractor_text = subject.send(abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)
            abstraction_schema.predicate_variants.each do |predicate_variant|
              ranges = parser.range_all(Regexp.escape(predicate_variant))
              if ranges.any?
                ranges.each do |range|
                  sentence = parser.find_sentence(range)
                  if sentence
                    abstraction_schema.object_values.each do |object_value|
                      object_value.object_variants.each do |object_variant|
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
                            suggest(abstraction, abstraction_source, sentence[:sentence], subject.id, subject_type, abstraction_source.from_method, object_value, nil, nil)
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

        def suggest(abstraction, abstraction_source, match_value, source_id, source_type, source_method, object_value, unknown, not_applicable)
          match_value.strip! unless match_value.nil?
          suggestion = abstraction.detect_suggestion(object_value.value) unless object_value.nil?
          if !suggestion
            suggestion_status_needs_review = Abstractor::SuggestionStatus.where(name: 'Needs review').first
            suggestion = Abstractor::Suggestion.create(
                                                                abstraction: abstraction,
                                                                suggestion_status: suggestion_status_needs_review,
                                                                suggested_value: object_value.try(:value),
                                                                unknown: unknown
                                                                )
            suggestion.suggestion_object_value = Abstractor::SuggestionObjectValue.new(object_value: object_value)
          end

          suggestion_source = suggestion.detect_suggestion_source(abstraction_source, match_value, source_id, source_type)
          if !suggestion_source
            Abstractor::SuggestionSource.create(
                                              abstraction_source: abstraction_source,
                                              suggestion: suggestion,
                                              match_value: match_value,
                                              source_id: source_id,
                                              source_type: source_type,
                                              source_method: source_method
                                             )
          end
          suggestion
        end

        def create_unknown_suggestion_name_only(subject, abstraction)
          abstraction_sources.each do |abstraction_source|
            abstractor_text = subject.send(abstraction_source.from_method)
            parser = Abstractor::Parser.new(abstractor_text)
            #Create an 'unknown' suggestion based on match name only if we have not made a suggstion
            if abstraction.suggestions(true).empty?
              abstraction_schema.predicate_variants.each do |predicate_variant|
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
                        suggest(abstraction, abstraction_source, predicate_variant.downcase, subject.id, subject_type, abstraction_source.from_method, nil, true, nil)
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def create_unknown_suggestion(subject, abstraction, abstraction_source)
          #Create an 'unknown' suggestion based on matching nothing only if we have not made a suggstion
          if abstraction.suggestions(true).empty?
            suggest(abstraction, abstraction_source, nil, subject.id, subject_type, abstraction_source.from_method, nil, true, nil)
          end
        end

        def groupable?
          !subject_group_member.nil?
        end
      end
    end
  end
end