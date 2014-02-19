module Abstractor
  class RelationType < ActiveRecord::Base
    include Abstractor::Methods::Models::RelationType
  end
end