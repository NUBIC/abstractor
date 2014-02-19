module Abstractor
  module SuggestionStatusCustomMethods
  end

  class SuggestionStatus < ActiveRecord::Base
    include Abstractor::Methods::Models::SuggestionStatus
    include Absgtractor::SuggestionStatusCustomMethods
  end
end