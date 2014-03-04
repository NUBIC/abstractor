module Abstractor
  module AbstractorAbstractionGroupCustomMethods
  end

  class AbstractorAbstractionGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionGroup
    include Abstractor::AbstractorAbstractionGroupCustomMethods
  end
end