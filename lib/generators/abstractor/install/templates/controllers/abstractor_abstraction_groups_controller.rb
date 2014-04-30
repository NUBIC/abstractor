module Abstractor
  module AbstractorAbstractionGroupsControllerCustomMethods
    def create
      super
    end

    def destroy
      super
    end
  end

  class AbstractorAbstractionGroupsController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractorAbstractionGroupsController
    include Abstractor::AbstractorAbstractionGroupsControllerCustomMethods
  end
end
