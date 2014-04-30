module Abstractor
  class AbstractorObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectValue
    # @!parse extend Moo::ClassMethods
  end
end