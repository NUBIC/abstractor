module Abstractor
  module SuggestionCustomMethods
  end

  class Suggestion < ActiveRecord::Base
    include Abstractor::Methods::Models::Suggestion
    include Abstractor::SuggestionCustomMethods
  end
end