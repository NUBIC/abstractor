module Abstractor
  class AbstractorSubject < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubject
  end
end