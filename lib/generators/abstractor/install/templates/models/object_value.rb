module Abstractor
  module ObjectValueCustomMethods
  end

  class ObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::ObjectValue
    include Abstractor::ObjectValueCustomMethods
  end
end