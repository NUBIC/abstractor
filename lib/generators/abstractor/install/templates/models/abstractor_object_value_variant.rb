module Abstractor
  module AbstractorObjectValueVariantCustomMethods
  end

  class AbstractorObjectValueVariant < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorObjectValueVariant
    include Abstractor::AbstractorObjectValueVariantCustomMethods
  end
end