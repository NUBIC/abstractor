module Abstractor
  class AbstractorAbstractionGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionGroup
    # @!parse extend Moo::ClassMethods
  end
end