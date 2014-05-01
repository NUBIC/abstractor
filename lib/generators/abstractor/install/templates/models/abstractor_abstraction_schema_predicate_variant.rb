module Abstractor
  module AbstractorAbstractionSchemaPredicateVariantCustomMethods
  end

  class AbstractorAbstractionSchemaPredicateVariant < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSchemaPredicateVariant
    include Abstractor::AbstractorAbstractionSchemaPredicateVariantCustomMethods
  end
end