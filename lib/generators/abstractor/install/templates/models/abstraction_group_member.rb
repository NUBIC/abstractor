module Abstractor
  module AbstractionGroupMemberCustomMethods
  end

  class AbstractionGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractionGroupMember
    include Abstractor::AbstractionGroupMemberCustomMethods
  end
end