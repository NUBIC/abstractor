module Abstractor
  module RuleTypeCustomMethods
  end

  class RuleType < ActiveRecord::Base
    include Abstractor::Methods::Models::RuleType
    include Abstractor::RuleTypeCustomMethods
  end
end