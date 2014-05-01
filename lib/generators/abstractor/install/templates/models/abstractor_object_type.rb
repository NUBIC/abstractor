module Abstractor
  module AbstractorObjectTypeCustomMethods
  end

  class AbstractorObjectType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectType
    include Abstractor::AbstractorObjectTypeCustomMethods
  end
end