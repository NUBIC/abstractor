module Abstractor
  module AbstractorAbstractionGroupMemberCustomMethods
  end

  class AbstractorAbstractionGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorAbstractionGroupMember
    include Abstractor::AbstractorAbstractionGroupMemberCustomMethods
  end
end