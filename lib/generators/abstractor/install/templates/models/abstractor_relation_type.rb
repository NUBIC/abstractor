module Abstractor
  module AbstractorRelationTypeCustomMethods
  end

  class AbstractorRelationType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorRelationType
    include Abstractor::AbstractorRelationTypeCustomMethods
  end
end