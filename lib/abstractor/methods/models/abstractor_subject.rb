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


          base.send :attr_accessible, :abstractor_abstraction_schema, :abstractor_abstraction_schema_id, :abstractor_rule_type, :abstractor_rule_type_id, :subject_type, :dynamic_list_method
          base.send(:include, InstanceMethods)
        end

        module InstanceMethods
          ##
          # Creates or finds and instance of an Abstactor::AbstractorAbstraction.
          # The method will create instances of Abstractor::AbstractorSuggestion and
          # Abstractor::AbstractorSuggestionSource for the abstractable entity
          # passed via the about parameter.
          #
          # The Abstractor::AbstractorSubject#abstractor_rule_type attribute determines the abstraction strategy:
          #
          # * 'name/value': attempts to search for non-negated sentences mentioning of an Abstractor::AbstractorAbstractionSchema#predicate and an Abstractor::AbstractorObjectValue
          # * 'value': attempts to search for non-negated sentences mentioning an Abstractor::AbstractorObjectValue
          # * 'unknown': will automatically create an 'unknown' Abstractor::AbstractorSuggestion
          # * 'custom': will create instances of Abstractor::AbstractorSuggestion based on custom logic delegated to the method on the about parameter configured in AbstractorAbstractionSource#custom_method
          #
          # @param [ActiveRecord::Base] about the entity abstract.  An instnace of the class specified in the Abstractor::AbstractorSubject#subject_type attribute.
          # @return [void]
          def abstract(about)
            abstractor_abstraction = about.find_or_create_abstractor_abstraction(abstractor_abstraction_schema, self)
            case abstractor_rule_type.name
            when 'name/value'
              abstract_name_value(about, abstractor_abstraction)
            when 'value'
              abstract_value(about, abstractor_abstraction)
            when 'unknown'
              abstract_unknown(about, abstractor_abstraction)
            when 'custom'
              abstract_custom(about, abstractor_abstraction)
            end
          end

          # Cycle through instances of Abstractor::AbstractorSuggestionSources
          # --each time calling the method on the about paramter configured by
          # the AbstractorAbstractionSource#custom_method attribute.
          # Setting up an Abstractor::AbstractorSubject with a
          # 'custom' rule type obligates the developer to implement an instance
          # method on the abstractable entitty to make suggestions as
          # appropriate.  The 'custom' rule type is intened to faciliate a
          # way to generate suggestions in a completely customizable way.
          #
          # @param [ActiveRecord::Base] about the entity to abstraction
          # @param [Abstractor::AbstractorAbstraction] abstractor_abstraction the instance of an abstractor abstraction
          # @return [void]
          def abstract_custom(about, abstractor_abstraction)
            abstractor_abstraction_sources.each do |abstractor_abstraction_source|
              suggested_values = about.send(abstractor_abstraction_source.custom_method)
              suggested_values.each do |suggested_value|
                suggest(abstractor_abstraction, abstractor_abstraction_source, nil, nil, about.id, about.class.to_s, abstractor_abstraction_source.from_method, suggested_value, nil, nil, abstractor_abstraction_source.custom_method)
              end
              create_unknown_abstractor_suggestion(about, abstractor_abstraction, abstractor_abstraction_source)
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
              abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
                abstractor_text = source[:source_type].find(source[:source_id]).send(source[:source_method])
                abstractor_object_value_ids = abstractor_abstraction_schema.abstractor_object_values.map(&:id)

                adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
                case adapter
                when 'sqlserver'
                  abstractor_object_value_variants = Abstractor::AbstractorObjectValueVariant.where("abstractor_object_value_id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} LIKE ('%' + abstractor_object_value_variants.value + '%'))", abstractor_object_value_ids, source[:source_id]).all
                when 'sqlite3'
                  abstractor_object_value_variants = Abstractor::AbstractorObjectValueVariant.where("abstractor_object_value_id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} LIKE ('%' || abstractor_object_value_variants.value || '%'))", abstractor_object_value_ids, source[:source_id]).all
                when 'postgresql'
                  abstractor_object_value_variants = Abstractor::AbstractorObjectValueVariant.where("abstractor_object_value_id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} ILIKE ('%' || abstractor_object_value_variants.value || '%'))", abstractor_object_value_ids, source[:source_id]).all
                end

                abstractor_object_values = abstractor_object_value_variants.map(&:abstractor_object_value).uniq

                adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
                case adapter
                when 'sqlserver'
                  abstractor_object_values.concat(Abstractor::AbstractorObjectValue.where("abstractor_object_values.id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} LIKE ('%' + abstractor_object_values.value + '%'))", abstractor_object_value_ids, source[:source_id]).all).uniq
                when 'sqlite3'
                  abstractor_object_values.concat(Abstractor::AbstractorObjectValue.where("abstractor_object_values.id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} LIKE ('%' || abstractor_object_values.value || '%'))", abstractor_object_value_ids, source[:source_id]).all).uniq
                when 'postgresql'
                  abstractor_object_values.concat(Abstractor::AbstractorObjectValue.where("abstractor_object_values.id in (?) AND EXISTS (SELECT 1 FROM #{source[:source_type].table_name} WHERE #{source[:source_type].table_name}.id = ? AND #{source[:source_type].table_name}.#{source[:source_method]} ILIKE ('%' || abstractor_object_values.value || '%'))", abstractor_object_value_ids, source[:source_id]).all).uniq
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
                            suggest(abstractor_abstraction, abstractor_abstraction_source, object_variant.downcase, sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], abstractor_object_value, nil, nil, nil)
                          end
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
              abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
                abstractor_text = source[:source_type].find(source[:source_id]).send(source[:source_method])
                parser = Abstractor::Parser.new(abstractor_text)
                abstractor_abstraction_schema.predicate_variants.each do |predicate_variant|
                  abstractor_abstraction_schema.abstractor_object_values.each do |abstractor_object_value|
                    abstractor_object_value.object_variants.each do |object_variant|
                      match_value = "#{Regexp.escape(predicate_variant)}:\s*#{Regexp.escape(object_variant)}"
                      matches = parser.scan(match_value, word_boundary: true).uniq
                      matches.each do |match|
                        suggest(abstractor_abstraction, abstractor_abstraction_source, match, match, source[:source_id], source[:source_type].to_s, source[:source_method], abstractor_object_value, nil, nil, nil)
                      end

                      match_value = "#{Regexp.escape(predicate_variant)}#{Regexp.escape(object_variant)}"
                      matches = parser.scan(match_value, word_boundary: true).uniq
                      matches.each do |match|
                        suggest(abstractor_abstraction, abstractor_abstraction_source, match, match, source[:source_id], source[:source_type].to_s, source[:source_method], abstractor_object_value, nil, nil, nil)
                      end
                    end
                  end
                end
              end
            end
          end

          def abstract_sentential_name_value(about, abstractor_abstraction)
            abstractor_abstraction_sources.each do |abstractor_abstraction_source|
              abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
                abstractor_text = source[:source_type].find(source[:source_id]).send(source[:source_method])
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
                                suggest(abstractor_abstraction, abstractor_abstraction_source, sentence[:sentence], sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], abstractor_object_value, nil, nil, nil)
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
          end

          def suggest(abstractor_abstraction, abstractor_abstraction_source, match_value, sentence_match_value, source_id, source_type, source_method, suggested_value, unknown, not_applicable, custom_method)
            match_value.strip! unless match_value.nil?
            sentence_match_value.strip! unless sentence_match_value.nil?
            if abstractor_object_value?(suggested_value)
              abstractor_object_value = suggested_value
              suggested_value = suggested_value.value
            end
            abstractor_suggestion = abstractor_abstraction.detect_abstractor_suggestion(suggested_value) unless suggested_value.nil?
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

            abstractor_suggestion_source = abstractor_suggestion.detect_abstractor_suggestion_source(abstractor_abstraction_source, sentence_match_value, source_id, source_type)
            if !abstractor_suggestion_source
              Abstractor::AbstractorSuggestionSource.create(
                                                abstractor_abstraction_source: abstractor_abstraction_source,
                                                abstractor_suggestion: abstractor_suggestion,
                                                match_value: match_value,
                                                sentence_match_value: sentence_match_value,
                                                source_id: source_id,
                                                source_type: source_type,
                                                source_method: source_method,
                                                custom_method: custom_method
                                               )
            end
            abstractor_suggestion
          end

          def abstractor_object_value?(suggested_value)
            suggested_value.instance_of?(Abstractor::AbstractorObjectValue)
          end

          def create_unknown_abstractor_suggestion_name_only(about, abstractor_abstraction)
            abstractor_abstraction_sources.each do |abstractor_abstraction_source|
              abstractor_abstraction_source.normalize_from_method_to_sources(about).each do |source|
                abstractor_text = source[:source_type].find(source[:source_id]).send(source[:source_method])
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
                            suggest(abstractor_abstraction, abstractor_abstraction_source, predicate_variant.downcase, sentence[:sentence], source[:source_id], source[:source_type].to_s, source[:source_method], nil, true, nil, nil)
                          end
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
              if abstractor_abstraction.abstractor_suggestions(true).empty?
                suggest(abstractor_abstraction, abstractor_abstraction_source, nil, nil, source[:source_id], source[:source_type].to_s, source[:source_method], nil, true, nil, nil)
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