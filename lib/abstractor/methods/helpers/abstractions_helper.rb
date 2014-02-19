module Abstractor
  module Methods
    module Helpers
      module AbstractionsHelper
        def abstraction_status_options
          Abstractor::Abstraction::STATUSES.map{|s| [s,s]}
        end
      end
    end
  end
end
