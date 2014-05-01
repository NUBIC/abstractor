module Abstractor
  module AbstractorSuggestionCustomMethods
  end

  class AbstractorSuggestion < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestion
    include Abstractor::AbstractorSuggestionCustomMethods
  end
end