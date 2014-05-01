module Abstractor
  module AbstractorAbstractionsControllerCustomMethods
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

  class AbstractorAbstractionsController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractorAbstractionsController
    include Abstractor::AbstractorAbstractionsControllerCustomMethods
  end
end