module Abstractor
  class SuggestionsController < Abstractor::ApplicationController
    include Abstractor::Methods::Controllers::SuggestionsController
  end
end

# class AbstractorSuggestionsController < ApplicationController
#   include Aker::Rails::SecuredController
#
#   before_filter :set_abstractor_suggestion, :only => [:update]
#
#   def update
#     respond_to do |format|
#       if @abstractor_suggestion.update_attributes(params[:abstractor_suggestion])
#         format.html { redirect_to(abstractor_abstraction_path(@abstractor_abstraction)) }
#       else
#         format.html { render "abstractor_abstractions/show" }
#       end
#     end
#   end
#
#   private
#     def set_abstractor_suggestion
#       @abstractor_abstraction = AbstractorAbstraction.find(params[:abstractor_abstraction_id])
#       @abstractor_suggestion = AbstractorSuggestion.find(params[:id])
#       @subject = @abstractor_abstraction.subject
#     end
# end
