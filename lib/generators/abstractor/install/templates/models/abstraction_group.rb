module Abstractor
  module AbstractionGroupCustomMethods
  end

  class AbstractionGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionGroup
    include Abstractor::AbstractionGroupCustomMethods
  end
end