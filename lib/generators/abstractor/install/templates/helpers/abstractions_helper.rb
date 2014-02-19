module Abstractor
  module AbstractionsHelperCustomMethods
  end

  module AbstractionsHelper
    include Abstractor::Methods::Helpers::AbstractionsHelper
    include Abstractor::AbstractionsHelperCustomMethods
  end
end