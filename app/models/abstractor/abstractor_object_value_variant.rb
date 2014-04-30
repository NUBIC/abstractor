module Abstractor
  class AbstractorObjectValueVariant < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectValueVariant
    # @!parse extend Moo::ClassMethods
  end
end