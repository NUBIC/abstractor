module Abstractor
  module AbstractorSubjectGroupMemberCustomMethods
  end

  class AbstractorSubjectGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectGroupMember
    include Abstractor::AbstractorSubjectGroupMemberCustomMethods
  end
end