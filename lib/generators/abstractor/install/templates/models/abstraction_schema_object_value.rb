module Abstractor
  module AbstractionSchemaObjectValueCustomMethods
  end

  class AbstractionSchemaObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSchemaObjectValue
    include Abstractor::AbstractionSchemaObjectValueCustomMethods
  end
end