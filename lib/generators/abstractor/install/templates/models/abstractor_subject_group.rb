module Abstractor
  module AbstractorSubjectGroupCustomMethods
  end

  class AbstractorSubjectGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectGroup
    include Abstractor::AbstractorSubjectGroupCustomMethods
  end
end