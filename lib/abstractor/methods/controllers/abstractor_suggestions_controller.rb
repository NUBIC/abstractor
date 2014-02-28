module Abstractor
  module Methods
    module Controllers
      module AbstractorSuggestionsController
        def self.included(base)
          base.send :before_filter, :set_abstractor_suggestion, :only => [:update]
        end

        def update
          respond_to do |format|
            if @abstractor_suggestion.update_attributes(params[:abstractor_suggestion])
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
      end
    end
  end
end
