module Abstractor
  class AbstractionGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionGroup
  end
end