module Abstractor
  module AbstractionSourceCustomMethods
  end

  class AbstractionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSource
    include Abstractor::AbstractionSourceCustomMethods
  end
end