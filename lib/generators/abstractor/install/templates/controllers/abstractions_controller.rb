module Abstractor
  module AbstractionsControllerCustomMethods
    def index
      super
    end

    def show
      super
    end

    def edit
      super
    end

    def update
      super
    end
  end

  class AbstractionsController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractionsController
    include Abstractor::AbstractionsControllerCustomMethods
  end
end