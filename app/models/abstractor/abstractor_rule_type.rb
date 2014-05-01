module Abstractor
  class AbstractorRuleType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorRuleType
    # @!parse extend Moo::ClassMethods
  end
end