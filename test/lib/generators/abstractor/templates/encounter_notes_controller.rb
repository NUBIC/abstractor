class EncounterNotesController < ApplicationController
  def edit
    @encounter_note = EncounterNote.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end