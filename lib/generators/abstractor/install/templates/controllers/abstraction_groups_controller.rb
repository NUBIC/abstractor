module Abstractor
  module AbstractionGroupsControllerCustomMethods
    def create
      super
    end

    def destroy
      super
    end
  end

  class AbstractionGroupsController < ApplicationController
    include Abstractor::Methods::Controllers::AbstractionGroupsController
    include Abstractor::AbstractionGroupsControllerCustomMethods
  end
end
