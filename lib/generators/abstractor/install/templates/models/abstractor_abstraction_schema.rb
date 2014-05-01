module Abstractor
  module AbstractorAbstractionSchemaCustomMethods
  end

  class AbstractorAbstractionSchema < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSchema
    include Abstractor::AbstractorAbstractionSchemaCustomMethods
  end
end