class ImagingExamsController < ApplicationController
  def edit
    @imaging_exam = ImagingExam.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end