module Abstractor
  module SubjectGroupCustomMethods
  end

  class SubjectGroup < ActiveRecord::Base
    include Abstractor::Methods::Models::SubjectGroup
    include Abstractor::SubjectGroupCustomMethods
  end
end