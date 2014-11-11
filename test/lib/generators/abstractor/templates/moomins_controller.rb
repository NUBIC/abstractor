class MoominsController < ApplicationController
  def edit
    @moomin = Moomin.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end