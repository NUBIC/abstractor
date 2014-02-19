module Abstractor
  class Abstraction < ActiveRecord::Base
    include Abstractor::Methods::Models::Abstraction
  end
end