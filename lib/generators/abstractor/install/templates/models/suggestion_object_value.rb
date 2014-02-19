module Abstractor
  module SuggestionObjectValueCustomMethods
  end

  class SuggestionObjectValue < ActiveRecord::Base
    include Abstractor::Methods::Models::SuggestionObjectValue
    include Abstractor::SuggestionObjectValueCustomMethods
  end
end