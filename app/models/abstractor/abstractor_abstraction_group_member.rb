module Abstractor
  class AbstractorAbstractionGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionGroupMember
    # @!parse extend Moo::ClassMethods
  end
end