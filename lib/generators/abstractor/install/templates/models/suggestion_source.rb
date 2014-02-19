module Abstractor
  module SuggestionSourceCustomMethods
  end

  class SuggestionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::SuggestionSource
    include Abstractor::SuggestionSourceCustomMethods
  end
end