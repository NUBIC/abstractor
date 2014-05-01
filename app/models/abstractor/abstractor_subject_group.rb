module Abstractor
  class AbstractorSubjectGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectGroup
    # @!parse extend Moo::ClassMethods
  end
end