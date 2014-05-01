module Abstractor
  module AbstractorAbstractionSchemaRelationCustomMethods
  end

  class AbstractorAbstractionSchemaRelation < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSchemaRelation
    include Abstractor::AbstractorAbstractionSchemaRelationCustomMethods
  end
end
