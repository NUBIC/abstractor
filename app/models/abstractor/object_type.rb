module Abstractor
  class ObjectType < ActiveRecord::Base
    include Abstractor::Methods::Models::ObjectType
  end
end