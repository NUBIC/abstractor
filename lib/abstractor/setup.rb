module Abstractor
  module Setup
    def self.system
      puts 'Setting up AbstractorObjectType'
      Abstractor::AbstractorObjectType.find_or_create_by_value('list')
      Abstractor::AbstractorObjectType.find_or_create_by_value('number')
      Abstractor::AbstractorObjectType.find_or_create_by_value('boolean')
      Abstractor::AbstractorObjectType.find_or_create_by_value('string')
      Abstractor::AbstractorObjectType.find_or_create_by_value('radio button list')
      Abstractor::AbstractorObjectType.find_or_create_by_value('date')
      Abstractor::AbstractorObjectType.find_or_create_by_value('dynamic list')

      puts 'Setting up AbstractorRuleType'
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name: 'name/value', description:'search for value associated with name')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name:'name', description: 'search for name match')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name:'value', description: 'search for value match')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name: 'unknown', description: 'do not try to abstract, always assign "unknown"')
      Abstractor::AbstractorRuleType.find_or_create_by_name_and_description(name:'custom', description: 'use whatever from_method returns as a value')

      puts 'Setting up AbstractorSuggestionStatus'
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Needs review')
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Accepted')
      Abstractor::AbstractorSuggestionStatus.find_or_create_by_name('Rejected')

      puts 'Setting up AbstractorRelationType'
      Abstractor::AbstractorRelationType.find_or_create_by_name('member_of')
      Abstractor::AbstractorRelationType.find_or_create_by_name('preceded_by')
    end
  end
end