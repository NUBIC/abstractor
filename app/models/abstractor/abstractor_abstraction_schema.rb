module Abstractor
  class AbstractorAbstractionSchema < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSchema
    # @!parse extend Moo::ClassMethods
  end
end