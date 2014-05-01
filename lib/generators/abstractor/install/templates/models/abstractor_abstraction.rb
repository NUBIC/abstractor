module Abstractor
  module AbstractorAbstractionCustomMethods
  end

  class AbstractorAbstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstraction
    include Abstractor::AbstractorAbstractionCustomMethods
  end
end