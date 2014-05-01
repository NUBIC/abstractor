module Abstractor
  module AbstractorAbstractionSourceCustomMethods
  end

  class AbstractorAbstractionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionSource
    include Abstractor::AbstractorAbstractionSourceCustomMethods
  end
end