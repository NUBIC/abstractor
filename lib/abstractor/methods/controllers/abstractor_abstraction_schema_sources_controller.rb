module Abstractor
  module Methods
    module Controllers
      module AbstractorAbstractionSchemaSourcesController
        def self.included(base)
          base.send :helper, :all

          base.send :skip_before_filter, :verify_authenticity_token, only: :configure_and_store_abstractions
          base.send :before_filter, :verify_custom_authenticity_token, only: :configure_and_store_abstractions
        end

        def configure_and_store_abstractions
          respond_to do |format|
            format.json do
              @abstractor_abstraction_schema_source = Abstractor::AbstractorAbstractionSchemaSource.find(params[:universe_id])
              @abstractor_abstraction_schema_source.configure_and_store_abstractions(params)
              if @abstractor_abstraction_schema_source.errors.any?
                render json: { status: :bad_request, errors: @abstractor_abstraction_schema_source.errors.full_messages }
              else
                render json: { status: :ok }
              end
            end
          end
        end

        private
          def set_abstractor_abstraction_schema
            @abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.find(params[:id])
          end

          def verify_custom_authenticity_token
            # TODO
            # check if data came from a trusted source
          end
      end
    end
  end
end
