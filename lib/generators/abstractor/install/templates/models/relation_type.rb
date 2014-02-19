module Abstractor
  module RelationTypeCustomMethods
  end

  class RelationType < ActiveRecord::Base
    include Abstractor::Methods::Models::RelationType
    include Abstractor::RelationTypeCustomMethods
  end
end