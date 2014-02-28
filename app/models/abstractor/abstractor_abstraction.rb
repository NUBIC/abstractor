module Abstractor
  class AbstractorAbstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstraction
  end
end