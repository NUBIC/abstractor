module Abstractor
  module AbstractionSchemaPredicateVariantCustomMethods
  end

  class AbstractionSchemaPredicateVariant < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSchemaPredicateVariant
    include Abstractor::AbstractionSchemaPredicateVariantCustomMethods
  end
end
a