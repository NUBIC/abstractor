module Abstractor
  module AbstractorSuggestionStatusCustomMethods
  end

  class AbstractorSuggestionStatus < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestionStatus
    include Absgtractor::AbstractorSuggestionStatusCustomMethods
  end
end