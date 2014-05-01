module Abstractor
  class AbstractorSubjectGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectGroupMember
    # @!parse extend Moo::ClassMethods
  end
end