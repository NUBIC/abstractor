module Abstractor
  class AbstractorSubjectRelation < ActiveRecord::Base
    include Abstractor::Methods::Models::AbstractorSubjectRelation
    # @!parse extend Moo::ClassMethods
  end
end