module Abstractor
  module AbstractionSchemaCustomMethods
  end

  class AbstractionSchema < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSchema
    include Abstractor::AbstractionSchemaCustomMethods
  end
end