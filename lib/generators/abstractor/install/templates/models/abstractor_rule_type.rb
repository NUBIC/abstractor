module Abstractor
  module AbstractorRuleTypeCustomMethods
  end

  class RuleType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorRuleType
    include Abstractor::AbstractorRuleTypeCustomMethods
  end
end