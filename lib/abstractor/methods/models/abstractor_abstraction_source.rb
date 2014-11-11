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

          def base.abstractor_text(source)
            text = source[:source_type].find(source[:source_id]).send(source[:source_method])
            if !source[:section_name].blank?
              abstractor_section = Abstractor::AbstractorSection.where(source_type: source[:source_type], source_method: source[:source_method], name: source[:section_name]).first
              if text =~ prepare_section_regular_expression(abstractor_section)
                text = $2
              else
                if abstractor_section.return_note_on_empty_section
                  text = text
                else
                  text = ''
                end
              end
            end

            text
          end

          def base.prepare_section_regular_expression(abstractor_section)
            regular_expression = nil
            if abstractor_section.abstractor_section_type.name == Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_CUSTOM
              regular_expression = abstractor_section.custom_regular_expression
            else
              regular_expression = abstractor_section.abstractor_section_type.regular_expression
            end
            regular_expression.gsub!('section_name_variants', abstractor_section.prepare_section_name_variants)
            regular_expression.gsub!('delimiter', abstractor_section.delimiter)
            Regexp.new(regular_expression, Regexp::IGNORECASE)
          end
        end

        def normalize_from_method_to_sources(about)
          sources = []
          fm = nil
          fm = about.send(from_method) unless from_method.blank?
          if fm.is_a?(String) || fm.nil?
            sources = [{ source_type: about.class , source_id: about.id , source_method: from_method, section_name: section_name }]
          else
            sources = fm
          end
          sources
        end
      end
    end
  end
end