module Abstractor
  class AbstractorAbstractionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSource
    # @!parse extend Moo::ClassMethods
  end
end