module Abstractor
  module Setup
    def self.system
      puts 'Setting up Abstractor::AbstractorObjectType'
      Abstractor::AbstractorObjectType.where(value: 'list').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'number').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'boolean').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'string').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'radio button list').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'date').first_or_create
      Abstractor::AbstractorObjectType.where(value: 'dynamic list').first_or_create

      puts 'Setting up Abstractor::AbstractorRuleType'
      Abstractor::AbstractorRuleType.where(name: 'name/value', description:'search for value associated with name').first_or_create
      Abstractor::AbstractorRuleType.where(name:'value', description: 'search for value match').first_or_create
      Abstractor::AbstractorRuleType.where(name: 'unknown', description: 'do not try to abstract, always assign "unknown"').first_or_create

      puts 'Setting up Abstractor::AbstractorSuggestionStatus'
      Abstractor::AbstractorSuggestionStatus.where(name: 'Needs review').first_or_create
      Abstractor::AbstractorSuggestionStatus.where(name: 'Accepted').first_or_create
      Abstractor::AbstractorSuggestionStatus.where(name: 'Rejected').first_or_create

      puts 'Setting up Abstractor::AbstractorRelationType'
      Abstractor::AbstractorRelationType.where(name: 'member_of').first_or_create
      Abstractor::AbstractorRelationType.where(name: 'preceded_by').first_or_create

      puts 'Setting up Abstractor::AbstractorAbstractionSourceType'
      Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: 'custom suggestion').first_or_create
      Abstractor::AbstractorAbstractionSourceType.where(name: 'indirect').first_or_create
    end
  end
end