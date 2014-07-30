module Abstractor
  class AbstractorAbstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstraction
    # @!parse include Abstractor::Methods::Models::AbstractorAbstraction::InstanceMethods
    # @!parse extend Abstractor::Methods::Models::AbstractorAbstraction::ClassMethods
  end
end