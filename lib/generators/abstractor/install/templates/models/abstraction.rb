module Abstractor
  module AbstractionCustomMethods
  end

  class Abstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::Abstraction
    include Abstractor::AbstractionCustomMethods
  end
end