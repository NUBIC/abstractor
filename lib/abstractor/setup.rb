module Abstractor
  module Setup
    def self.system
      puts 'Setting up Abstractor::AbstractorObjectType'
        Abstractor::Enum::ABSTRACTOR_OBJECT_TYPES.each do |abstractor_object_type|
        Abstractor::AbstractorObjectType.where(value: abstractor_object_type).first_or_create
      end

      puts 'Setting up Abstractor::AbstractorRuleType'
      Abstractor::AbstractorRuleType.where(name: Abstractor::Enum::ABSTRACTOR_RULE_TYPE_NAME_VALUE, description:'search for value associated with name').first_or_create
      Abstractor::AbstractorRuleType.where(name: Abstractor::Enum::ABSTRACTOR_RULE_TYPE_VALUE, description: 'search for value match').first_or_create
      Abstractor::AbstractorRuleType.where(name: Abstractor::Enum::ABSTRACTOR_RULE_TYPE_UNKNOWN, description: 'do not try to abstract, always assign "unknown"').first_or_create

      puts 'Setting up Abstractor::AbstractorSuggestionStatus'
      Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first_or_create
      Abstractor::AbstractorSuggestionStatus.where(name: 'Accepted').first_or_create
      Abstractor::AbstractorSuggestionStatus.where(name: 'Rejected').first_or_create

      puts 'Setting up Abstractor::AbstractorRelationType'
      Abstractor::AbstractorRelationType.where(name: 'member_of').first_or_create
      Abstractor::AbstractorRelationType.where(name: 'preceded_by').first_or_create

      puts 'Setting up Abstractor::AbstractorAbstractionSourceType'
      Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_NLP_SUGGESTION).first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_CUSTOM_SUGGESTION).first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_INDIRECT).first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_CUSTOM_NLP_SUGGESTION).first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_CUSTOM_NLP_SCHEMA).first_or_create

      puts 'Setting up Abstractor::AbstractorSectionType'
      Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_CUSTOM).first_or_create
      abstractor_section_type = Abstractor::AbstractorSectionType.where(name: Abstractor::Enum::ABSTRACTOR_SECTION_TYPE_NAME_VALUE).first_or_create
      abstractor_section_type.regular_expression = '(?<=^|[\r\n])(section_name_variants\s*)delimiter([^\r\n]*(?:[\r\n]+(?![A-Za-z].*delimiter).*)*)'
      abstractor_section_type.save!
    end
  end
end