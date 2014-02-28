module Abstractor
  class AbstractorObjectType < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectType
  end
end