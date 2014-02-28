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
            if @abstractor_abstraction.update_attributes(params[:abstractor_abstraction])
              format.html { redirect_to(abstractor_abstraction_path(@abstractor_abstraction)) }
            else
              format.html { render :action => "edit" }
            end
          end
        end

        private
          def set_abstractor_abstraction
            @abstractor_abstraction = Abstractor::AbstractorAbstraction.find(params[:id])
            @about = @abstractor_abstraction.about
          end
      end
    end
  end
end