module Abstractor
  class AbstractionSchema < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionSchema
  end
end