module Abstractor
  module AbstractorAbstractionSchemasControllerCustomMethods
    def show
      super
    end
  end

  class AbstractorAbstractionSchemasController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractorAbstractionSchemasController
    include Abstractor::AbstractorAbstractionSchemasControllerCustomMethods
  end
end
