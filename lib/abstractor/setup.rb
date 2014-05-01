module Abstractor
  module Setup
    def self.system
      Abstractor::AbstractorObjectType.create(:value => 'list')
      Abstractor::AbstractorObjectType.create(:value => 'number')
      Abstractor::AbstractorObjectType.create(:value => 'boolean')
      Abstractor::AbstractorObjectType.create(:value => 'string')
      Abstractor::AbstractorObjectType.create(:value => 'radio button list')

      Abstractor::AbstractorRuleType.create(:name => 'name/value', :description => 'search for value associated with name')
      Abstractor::AbstractorRuleType.create(:name =>'name', :description => 'search for name match')
      Abstractor::AbstractorRuleType.create(:name =>'value', :description => 'search for value match')
      Abstractor::AbstractorRuleType.create(:name =>'unknown', :description => 'do not try to abstract, always assign "unknown"')
      Abstractor::AbstractorRuleType.create(:name =>'custom', :description => 'use whatever from_method returns as a value')

      Abstractor::AbstractorSuggestionStatus.create(:name => 'Needs review')
      Abstractor::AbstractorSuggestionStatus.create(:name => 'Accepted')
      Abstractor::AbstractorSuggestionStatus.create(:name => 'Rejected')

      Abstractor::AbstractorRelationType.create(:name => 'member_of')
      Abstractor::AbstractorRelationType.create(:name => 'preceded_by')
    end
  end
end