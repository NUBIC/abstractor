module Abstractor
  module Methods
    module Controllers
      module SuggestionsController
        def self.included(base)
          base.send :before_filter, :set_suggestion, :only => [:update]
        end

        def update
          respond_to do |format|
            if @suggestion.update_attributes(params[:suggestion])
              format.html { redirect_to(abstraction_path(@abstraction)) }
            else
              format.html { render "abstractions/show" }
            end
          end
        end

        private
          def set_suggestion
            @abstraction = Abstractor::Abstraction.find(params[:abstraction_id])
            @suggestion = Abstractor::Suggestion.find(params[:id])
            @subject = @abstraction.subject
          end
      end
    end
  end
end
