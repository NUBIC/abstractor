module Abstractor
  class AbstractorSubject < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubject
    # @!parse include Abstractor::Methods::Models::AbstractorSubject::InstanceMethods
  end
end