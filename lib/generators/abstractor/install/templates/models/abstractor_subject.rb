module Abstractor
  module AbstractorSubjectCustomMethods
  end

  class AbstractorSubject < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubject
    include Abstractor::AbstractorSubjectCustomMethods
  end
end