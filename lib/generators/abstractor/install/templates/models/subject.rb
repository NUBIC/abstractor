module Abstractor
  module SubjectCustomMethods
  end

  class Subject < ActiveRecord::Base
    include Abstractor::Methods::Models::Subject
    include Abstractor::SubjectCustomMethods
  end
end