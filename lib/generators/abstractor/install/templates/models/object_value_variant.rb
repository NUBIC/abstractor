module Abstractor
  module ObjectValueVariantCustomMethods
  end

  class ObjectValueVariant < ActiveRecord::Base
    include Abstractor::Methods::Models::ObjectValueVariant
    include Abstractor::ObjectValueVariantCustomMethods
  end
end