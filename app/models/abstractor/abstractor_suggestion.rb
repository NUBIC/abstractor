module Abstractor
  class AbstractorSuggestion < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSuggestion
    # @!parse extend Moo::ClassMethods
  end
end