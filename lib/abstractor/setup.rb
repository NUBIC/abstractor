module Abstractor
  module Setup
    def self.system
      puts 'Setting up Abstractor::AbstractorObjectType'
      Abstractor::AbstractorObjectType.find_or_create_by_value('list')
      Abstractor::AbstractorObjectType.find_or_create_by_value('number')
      Abstractor::AbstractorObjectType.find_or_create_by_value('boolean')
      Abstractor::AbstractorObjectType.find_or_create_by_value('string')
      Abstractor::AbstractorObjectType.find_or_create_by_value('radio button list')
      Abstractor::AbstractorObjectType.find_or_create_by_value('date')
      Abstractor::AbstractorObjectType.find_or_create_by_value('dynamic list')
      Abstractor::AbstractorObjectType.where(value: 'text').first_or_create

      puts 'Setting up Abstractor::AbstractorRuleType'
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name: 'name/value', description:'search for value associated with name')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name:'value', description: 'search for value match')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name: 'unknown', description: 'do not try to abstract, always assign "unknown"')

      puts 'Setting up Abstractor::AbstractorSuggestionStatus'
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Needs review')
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Accepted')
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Rejected')

      puts 'Setting up Abstractor::AbstractorRelationType'
      Abstractor::AbstractorRelationType.find_or_create_by_name('member_of')
      Abstractor::AbstractorRelationType.find_or_create_by_name('preceded_by')

      puts 'Setting up Abstractor::AbstractorAbstractionSourceType'
      Abstractor::AbstractorAbstractionSourceType.find_or_create_by_name('nlp suggestion')
      Abstractor::AbstractorAbstractionSourceType.find_or_create_by_name('custom suggestion')
      Abstractor::AbstractorAbstractionSourceType.find_or_create_by_name('indirect')
    end
  end
end