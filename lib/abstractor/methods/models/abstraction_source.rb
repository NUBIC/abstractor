module Abstractor
  module Methods
    module Models
      module AbstractionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_subject, class_name: 'Abstractor::Subject', foreign_key: :abstractor_subject_id
          base.send :has_many, :suggestion_sources
          base.send :has_many, :abstractions, :through => :suggestion_sources

          base.send :attr_accessible, :abstractor_subject, :subject_id, :deleted_at, :from_method
        end
      end
    end
  end
end

