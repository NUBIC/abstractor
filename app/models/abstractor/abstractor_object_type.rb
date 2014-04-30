module Abstractor
  class AbstractorObjectType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectType
    # @!parse extend Moo::ClassMethods
  end
end