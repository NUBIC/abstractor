module Abstractor
  module ObjectTypeCustomMethods
  end

  class ObjectType < ActiveRecord::Base
    include Abstractor::Methods::Models::ObjectType
    include Abstractor::ObjectTypeCustomMethods
  end
end