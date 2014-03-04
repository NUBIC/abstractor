module Abstractor
  module AbstractorObjectValueCustomMethods
  end

  class AbstractorObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectValue
    include Abstractor::AbstractorObjectValueCustomMethods
  end
end