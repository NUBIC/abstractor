module Abstractor
  module AbstractionSchemaRelationCustomMethods
  end

  class AbstractionSchemaRelation < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSchemaRelation
    include Abstractor::AbstractionSchemaRelationCustomMethods
  end
end
