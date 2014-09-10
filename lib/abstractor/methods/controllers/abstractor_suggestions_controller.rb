module Abstractor
  module Methods
    module Controllers
      module AbstractorSuggestionsController
        def self.included(base)
          base.send :before_filter, :set_abstractor_suggestion, :only => [:update]
        end

        def update
          respond_to do |format|
            if @abstractor_suggestion.update_attributes(abstractor_suggestion_params)
              format.html { redirect_to(abstractor_abstraction_path(@abstractor_abstraction)) }
            else
              format.html { render "abstractor_abstractions/show" }
            end
          end
        end

        private
          def set_abstractor_suggestion
            @abstractor_abstraction = Abstractor::AbstractorAbstraction.find(params[:abstractor_abstraction_id])
            @abstractor_suggestion = Abstractor::AbstractorSuggestion.find(params[:id])
            @about = @abstractor_abstraction.about
          end

          def abstractor_suggestion_params
            params.require(:abstractor_suggestion).permit(:id, :abstractor_abstraction_id, :abstractor_suggestion_status_id, :suggested_value, :unknown, :not_applicable, :deleted_at, :_destroy)
          end
      end
    end
  end
end