module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionGroupsController
        def self.included(base)
          base.send :helper, :all
          base.send :before_filter, :set_abstractor_abstraction_group, only: [:destroy, :update]
        end

        def create
          @abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.create(abstractor_subject_group_id: params[:abstractor_subject_group_id], about_type: params[:about_type], about_id: params[:about_id])
          @abstractor_abstraction_group.abstractor_subject_group.abstractor_subjects.each do |abstractor_subject|
            abstraction = abstractor_subject.abstractor_abstractions.build(about_id: params[:about_id], about_type: params[:about_type])
            abstraction.build_abstractor_abstraction_group_member(abstractor_abstraction_group: @abstractor_abstraction_group)
            abstraction.save!
          end

          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        def destroy
          if @abstractor_abstraction_group.soft_delete!
            flash[:notice] = "Group was successfully deleted."
          else
            flash[:error] = "Group could not be deactivated: #{abstractor_abstraction_group.errors.full_messages.join(',')}"
          end
          respond_to do |format|
            format.js   { head :no_content }
            format.json { head :no_content }
          end
        end

        def update
          abstractor_abstraction_value = params[:abstractor_abstraction_value]
          Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@abstractor_abstraction_group.abstractor_abstractions, abstractor_abstraction_value)
          respond_to do |format|
            format.html { render action: "edit", layout: false }
          end
        end

        private
          def set_abstractor_abstraction_group
            @abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.find(params[:id])
          end
      end
    end
  end
end