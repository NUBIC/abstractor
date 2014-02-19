module Abstractor
  class Suggestion < ActiveRecord::Base
    include Abstractor::Methods::Models::Suggestion
  end
end