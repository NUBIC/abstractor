module Abstractor
  class Subject < ActiveRecord::Base
    include Abstractor::Methods::Models::Subject
  end
end