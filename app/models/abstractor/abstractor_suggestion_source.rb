module Abstractor
  class AbstractorSuggestionSource < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestionSource
    # @!parse extend Moo::ClassMethods
  end
end