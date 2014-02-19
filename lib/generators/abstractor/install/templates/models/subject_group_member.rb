module Abstractor
  module SubjectGroupMemberCustomMethods
  end

  class SubjectGroupMember < ActiveRecord::Base
    include Abstractor::Methods::Models::SubjectGroupMember
    include Abstractor::SubjectGroupMemberCustomMethods
  end
end