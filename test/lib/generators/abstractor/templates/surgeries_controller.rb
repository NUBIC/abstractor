class SurgeriesController < ApplicationController
  def edit
    @surgery = Surgery.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end