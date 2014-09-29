module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionsController
        def self.included(base)
          base.send :before_filter, :set_abstractor_abstraction, :only => [:show, :edit, :update]
        end

        def index
        end

        def show
          respond_to do |format|
            format.html { render :layout => false }
          end
        end

        def edit
          respond_to do |format|
            format.html { render :layout => false }
          end
        end

        def update
          respond_to do |format|
            if @abstractor_abstraction.update_attributes(abstractor_abstraction_params)
              format.html { redirect_to(abstractor_abstraction_path(@abstractor_abstraction)) }
            else
              format.html { render :action => "edit" }
            end
          end
        end

        def update_all
          abstractor_abstraction_value = params[:abstractor_abstraction_value]
          @about = params[:about_type].constantize.find(params[:about_id])
          Abstractor::AbstractorAbstraction.update_abstractor_abstraction_other_value(@about.abstractor_abstractions, abstractor_abstraction_value)
          respond_to do |format|
            format.html { redirect_to :back }
          end
        end

        private
          def set_abstractor_abstraction
            @abstractor_abstraction = Abstractor::AbstractorAbstraction.find(params[:id])
            @about = @abstractor_abstraction.about
          end

          def abstractor_abstraction_params
            params.require(:abstractor_abstraction).permit(:id, :abstractor_subject_id, :value, :about_type, :about_id, :unknown, :not_applicable, :deleted_at, :_destroy,
            abstractor_indirect_sources_attributes: [:id, :abstractor_abstraction_id, :abstractor_abstraction_source_id, :source_type, :source_id, :source_method, :deleted_at, :_destroy]
            )
          end
      end
    end
  end
end