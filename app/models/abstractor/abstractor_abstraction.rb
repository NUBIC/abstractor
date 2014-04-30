module Abstractor
  class AbstractorAbstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstraction
    # @!parse extend Moo::ClassMethods
  end
end