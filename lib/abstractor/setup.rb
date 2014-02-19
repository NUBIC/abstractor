module Abstractor
  module Setup
    def self.system
      Abstractor::ObjectType.create(:value => 'list')
      Abstractor::ObjectType.create(:value => 'number')
      Abstractor::ObjectType.create(:value => 'boolean')

      Abstractor::RuleType.create(:name => 'name/value', :description => 'search for value associated with name')
      Abstractor::RuleType.create(:name =>'name', :description => 'search for name match')
      Abstractor::RuleType.create(:name =>'value', :description => 'search for value match')
      Abstractor::RuleType.create(:name =>'unknown', :description => 'do not try to abstract, always assign "unknown"')
      Abstractor::RuleType.create(:name =>'custom', :description => 'use whatever from_method returns as a value')

      Abstractor::SuggestionStatus.create(:name => 'Needs review')
      Abstractor::SuggestionStatus.create(:name => 'Accepted')
      Abstractor::SuggestionStatus.create(:name => 'Rejected')

      Abstractor::RelationType.create(:name => 'member_of')
      Abstractor::RelationType.create(:name => 'preceded_by')
    end
  end
end