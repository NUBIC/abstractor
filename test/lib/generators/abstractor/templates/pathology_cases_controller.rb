class PathologyCasesController < ApplicationController
  def edit
    @pathology_case = PathologyCase.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end