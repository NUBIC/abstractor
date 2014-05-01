module Abstractor
  module AbstractorSuggestionSourceCustomMethods
  end

  class AbstractorSuggestionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestionSource
    include Abstractor::AbstractorSuggestionSourceCustomMethods
  end
end