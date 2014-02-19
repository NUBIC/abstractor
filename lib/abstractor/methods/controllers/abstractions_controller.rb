module Abstractor
  module Methods
    module Controllers
      module AbstractionsController
        def self.included(base)
          base.send :before_filter, :set_abstraction, :only => [:show, :edit, :update]
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
            if @abstraction.update_attributes(params[:abstraction])
              format.html { redirect_to(abstraction_path(@abstraction)) }
            else
              format.html { render :action => "edit" }
            end
          end
        end

        private
          def set_abstraction
            @abstraction = Abstractor::Abstraction.find(params[:id])
            @subject = @abstraction.subject
          end
      end
    end
  end
end