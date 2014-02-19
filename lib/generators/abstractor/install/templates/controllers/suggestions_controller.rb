module Abstractor
  module SuggestionsControllerCustomMethods
    def update
      super
    end
  end

  class SuggestionsController < ApplicationController
    include Abstractor::Methods::Controllers::SuggestionsController
    include Abstractor::SuggestionsControllerCustomMethods
  end
end