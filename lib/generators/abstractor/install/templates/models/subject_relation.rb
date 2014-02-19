module Abstractor
  module SubjectRelationCustomMethods
  end

  class SubjectRelation < ActiveRecord::Base
    include Abstractor::Methods::Models::SubjectRelation
    include Abstractor::SubjectRelationCustomMethods
  end
end