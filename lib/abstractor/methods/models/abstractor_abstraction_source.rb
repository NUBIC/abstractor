module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_subject
          base.send :belongs_to, :abstractor_rule_type
          base.send :belongs_to, :abstractor_abstraction_source_type
          base.send :belongs_to, :abstractor_abstraction_source_section_type
          base.send :has_many, :abstractor_suggestion_sources
          base.send :has_many, :abstractor_abstractions, :through => :abstractor_suggestion_sources
          base.send :has_many, :abstractor_indirect_sources
          base.send :has_many, :abstractor_abstraction_source_section_name_variants
        end

        def normalize_from_method_to_sources(about)
          sources = []
          fm = nil
          fm = about.send(from_method) unless from_method.blank?
          if fm.is_a?(String) || fm.nil?
            sources = [{ source_type: about.class , source_id: about.id , source_method: from_method }]
          else
            sources = fm
          end
          sources
        end

        def abstractor_text(source)
          text = nil
          case abstractor_abstraction_source_section_type
          when nil, Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_SECTION_TYPE_FULL_NOTE
            text = source[:source_type].find(source[:source_id]).send(source[:source_method])
          when Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_SECTION_TYPE_NAME_VALUE, Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_SECTION_TYPE_CUSTOM
            if text =~ prepare_section_regular_expression
              text = $2
            else
              ''
            end
          end
          text
        end

        def prepare_section_regular_expression
          regular_expression = nil
          if abstractor_abstraction_source_section_type == Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_SECTION_TYPE_CUSTOM
            regular_expression = custom_section_regular_expression
          else
            regular_expression = abstractor_abstraction_source_section_type.regular_expression
          end
          Regexp.new(regular_expression.sub('section_name_variants', prepare_section_name_variants))
        end

        def prepare_section_name_variants
          abstractor_abstraction_source_section_name_variants.map(&:name).join('|')
        end
      end
    end
  end
end