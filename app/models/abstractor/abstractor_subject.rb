module Abstractor
  class AbstractorSubject < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubject
    # @!parse extend Moo::ClassMethods
  end
end