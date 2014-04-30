module Abstractor
  module AbstractorSuggestionsControllerCustomMethods
    def update
      super
    end
  end

  class AbstractorSuggestionsController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractorSuggestionsController
    include Abstractor::AbstractorSuggestionsControllerCustomMethods
  end
end