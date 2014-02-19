module Abstractor
  class AbstractionGroupsController < Abstractor::ApplicationController
    include Abstractor::Methods::Controllers::AbstractionGroupsController
  end
end

# class AbstractorAbstractionGroupsController < ApplicationController
#   def create
#     @abstractor_abstraction_group = AbstractorAbstractionGroup.create(abstractor_subject_group_id: params[:abstractor_subject_group_id], subject_type: params[:subject_type], subject_id: params[:subject_id])
#     @abstractor_abstraction_group.abstractor_subject_group.abstractor_subjects.each do |abstractor_subject|
#       abstractor_abstraction = abstractor_subject.abstractor_abstractions.build(subject_id: params[:subject_id])
#       abstractor_abstraction.build_abstractor_abstraction_group_member(abstractor_abstraction_group: @abstractor_abstraction_group)
#       abstractor_abstraction.save!
#     end
#
#     respond_to do |format|
#       format.html { render action: "edit", layout: false }
#     end
#   end
#
#   def destroy
#     abstractor_abstraction_group = AbstractorAbstractionGroup.find(params[:id])
#     if abstractor_abstraction_group.soft_delete!
#       flash[:notice] = "Group was successfully deleted."
#     else
#       flash[:error] = "Group could not be deactivated: #{abstractor_abstraction_group.errors.full_messages.join(',')}"
#     end
#     respond_to do |format|
#       format.js   { head :no_content }
#       format.json { head :no_content }
#     end
#   end
# end
