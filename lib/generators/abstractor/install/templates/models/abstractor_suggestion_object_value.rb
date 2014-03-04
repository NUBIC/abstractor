module Abstractor
  module AbstractorSuggestionObjectValueCustomMethods
  end

  class SuggestionObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestionObjectValue
    include Abstractor::AbstractorSuggestionObjectValueCustomMethods
  end
end