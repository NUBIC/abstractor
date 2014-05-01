module Abstractor
  module AbstractorAbstractionSchemaObjectValueCustomMethods
  end

  class AbstractorAbstractionSchemaObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSchemaObjectValue
    include Abstractor::AbstractorAbstractionSchemaObjectValueCustomMethods
  end
end