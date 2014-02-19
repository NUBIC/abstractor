module Abstractor
  module Methods
    module Controllers
      module AbstractionGroupsController
        def self.included(base)
          base.send :helper, :all
        end

        def create
          @abstraction_group = Abstractor::AbstractionGroup.create(subject_group_id: params[:subject_group_id], subject_type: params[:subject_type], subject_id: params[:subject_id])
          @abstraction_group.subject_group.subjects.each do |subject|
            abstraction = subject.abstractions.build(subject_id: params[:subject_id])
            abstraction.build_abstraction_group_member(abstraction_group: @abstraction_group)
            abstraction.save!
          end

          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        def destroy
          abstraction_group = Abstractor::AbstractionGroup.find(params[:id])
          if abstraction_group.soft_delete!
            flash[:notice] = "Group was successfully deleted."
          else
            flash[:error] = "Group could not be deactivated: #{abstraction_group.errors.full_messages.join(',')}"
          end
          respond_to do |format|
            format.js   { head :no_content }
            format.json { head :no_content }
          end
        end
      end
    end
  end
end