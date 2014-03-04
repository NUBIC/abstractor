module Abstractor
  module AbstractorSubjectRelationCustomMethods
  end

  class AbstractorSubjectRelation < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectRelation
    include Abstractor::AbstractorSubjectRelationCustomMethods
  end
end