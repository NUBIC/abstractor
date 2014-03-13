module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSource
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_subject
          base.send :has_many, :abstractor_suggestion_sources
          base.send :has_many, :abstractor_abstractions, :through => :abstractor_suggestion_sources

          base.send :attr_accessible, :abstractor_subject, :abstractor_subject_id, :deleted_at, :from_method
        end

        def normalize_from_method_to_sources(about)
          sources = []
          fm = about.send(from_method)
          if fm.is_a?(String) || fm.nil?
            sources = [{ source_type: about.class , source_id: about.id , source_method: from_method }]
          else
            sources = fm
          end
          sources
        end
      end
    end
  end
end