class RadiationTherapyRemotePrescriptionsController < ApplicationController
  def edit
    @radiation_therapy_remote_prescription = RadiationTherapyRemotePrescription.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end