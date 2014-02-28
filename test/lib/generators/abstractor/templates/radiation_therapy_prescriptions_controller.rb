class RadiationTherapyPrescriptionsController < ApplicationController
  def edit
    @radiation_therapy_prescription = RadiationTherapyPrescription.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end