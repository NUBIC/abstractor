module Abstractor
  class AbstractorRelationType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorRelationType
    # @!parse extend Moo::ClassMethods
  end
end