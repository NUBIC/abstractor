class ImagingExamsController < ApplicationController
  def edit
    @namespace_type ||= params[:namespace_type]
    @namespace_id ||= params[:namespace_id].to_i
    @imaging_exam = ImagingExam.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end