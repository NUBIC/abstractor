module Abstractor
  module Abstractable
    def self.included(base)
      base.class_eval do
        has_many :abstractor_abstractions, class_name: Abstractor::AbstractorAbstraction, as: :about

        has_many :abstractor_abstraction_groups, class_name: Abstractor::AbstractorAbstractionGroup, as: :about

        accepts_nested_attributes_for :abstractor_abstractions, allow_destroy: false

        def self.by_abstractor_suggestion_status(abstractor_suggestion_status)
          abstractor_suggestion_status_needs_review = Abstractor::AbstractorSuggestionStatus.where(:name => 'Needs review').first
          abstractor_suggestion_status_accepted= Abstractor::AbstractorSuggestionStatus.where(:name => 'Accepted').first
          abstractor_suggestion_status_rejected = Abstractor::AbstractorSuggestionStatus.where(:name => 'Rejected').first

          case abstractor_suggestion_status
          when 'needs_review'
            where(["EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstractor_abstraction_id AND aas.abstractor_suggestion_status_id = ? WHERE #{self.table_name}.id = aa.about_id)", abstractor_suggestion_status_needs_review])
          when 'reviewed'
            where(["EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstractor_abstraction_id WHERE #{self.table_name}.id = aa.about_id) AND NOT EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstractor_abstraction_id  AND aas.abstractor_suggestion_status_id = ? WHERE #{self.table_name}.id = aa.about_id)", abstractor_suggestion_status_needs_review])
          else
            where(nil)
          end
        end

        def self.abstractor_subjects
          Abstractor::AbstractorSubject.where(subject_type: self.to_s)
        end

        def self.abstractor_abstraction_schemas
          abstractor_subjects.map(&:abstractor_abstraction_schema)
        end

        def self.abstractor_subject_groups
          abstractor_subjects.map(&:abstractor_subject_group).uniq
        end

        def self.prepare_pivot_select
          select =[]
          abstraction_schemas.map(&:predicate).each do |predicate|
            select << "MAX(CASE WHEN data.predicate = '#{predicate}' THEN data.value ELSE NULL END) AS #{predicate}"
          end
          select = select.join(',')
        end

        scope :pivot_abstractions, (lambda do
          select = prepare_pivot_select
          joins = "JOIN
          (
          SELECT #{self.table_name}.id AS subject_id,
          #{select}
          FROM
          (SELECT   aas.predicate
                  , aas.id AS abstractor_abstraction_schema_id
                  , asb.subject_type
                  , aa.subject_id
                  , aa.value
          FROM abstractor_abstractions aa JOIN abstractor_subjects asb            ON aa.abstractor_subject_id = asb.id
                                          JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
          WHERE asb.subject_type = '#{self.to_s}'
          AND NOT EXISTS (
            SELECT 1
            FROM abstractor_abstraction_group_members aagm
            WHERE aa.id = aagm.abstraction_id
          )
          ) data join #{self.table_name} ON  data.subject_id = #{self.table_name}.id
          GROUP BY #{self.table_name}.id
          ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
          "
          joins(joins).select()
        end)

        scope :pivot_grouped_abstractions, (lambda do |subject_group_name|
          subject_group = subject_groups.detect { |subject_group| subject_group.name ==  subject_group_name }
          select = prepare_pivot_select
          joins = "JOIN
          (
          SELECT #{self.table_name}.id AS subject_id,
          #{select}
          FROM
          (SELECT   aas.predicate
                  , aas.id AS abstraction_schema_id
                  , asb.subject_type
                  , aa.subject_id
                  , aa.value
                  , aag.id AS abstraction_group_id
          FROM abstractor_abstractions aa JOIN abstractor_subjects asb                    ON aa.abstractor_subject_id = asb.id
                                          JOIN abstractor_abstraction_schemas aas         ON asb.abstractor_abstraction_schema_id = aas.id
                                          JOIN abstractor_abstraction_group_members aagm  ON aa.id = aagm.abstraction_id
                                          JOIN abstractor_abstraction_groups aag          ON aagm.abstractor_abstraction_group_id= aag.id
          WHERE asb.subject_type = '#{self.to_s}'
          AND aag.abstractor_subject_group_id = #{abstractor_subject_group.id}
          ) data join #{self.table_name} ON  data.subject_id = #{self.table_name}.id
          GROUP BY #{self.table_name}.id, abstractor_abstraction_group_id
          ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
          "
          joins(joins).select("#{self.table_name}.*, pivoted_abstractions.*")
        end)
      end
    end

    def abstract
      self.class.abstractor_subjects.each do |abstractor_subject|
        abstractor_subject.abstract(self)
      end
    end

    def detect_abstractor_abstraction(abstractor_subject)
      abstractor_abstractions(true).not_deleted.detect { |abstractor_abstraction| abstractor_abstraction.abstractor_subject == abstractor_subject }
    end

    def find_or_create_abstractor_abstraction(abstractor_abstraction_schema, abstractor_subject)
      if abstractor_abstraction = detect_abstractor_abstraction(abstractor_subject)
      else
        abstractor_abstraction = Abstractor::AbstractorAbstraction.create!(abstractor_subject: abstractor_subject, about: self)
        if abstractor_subject.groupable?
          abstractor_abstraction_group = find_or_create_abstractor_abstraction_group(abstractor_subject.abstractor_subject_group)
          abstractor_abstraction_group.abstractor_abstractions << abstractor_abstraction
        end
      end
      abstractor_abstraction
    end

    def detect_abstractor_abstraction_group(abstractor_subject_group)
      abstractor_abstraction_groups(true).detect { |abstractor_abstraction_group| abstractor_abstraction_group.abstractor_subject_group ==  abstractor_subject_group }
    end

    def find_or_create_abstractor_abstraction_group(abstractor_subject_group)
      if abstractor_abstraction_group = detect_abstractor_abstraction_group(abstractor_subject_group)
      else
        abstractor_abstraction_group = Abstractor::AbstractorAbstractionGroup.create(abstractor_subject_group: abstractor_subject_group, about: self)
      end
      abstractor_abstraction_group
    end

    def abstractor_abstractions_by_abstractor_suggestion_status(abstractor_suggestion_statuses)
      abstractor_abstractions.map(&:abstractor_suggestions).flatten.select { |as| Array.new(abstractor_suggestion_statuses).any? { |abstractor_suggestion_status| as.abstractor_suggestion_status == abstractor_suggestion_status } }
    end

    def remove_abstractions
      abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
          abstractor_suggestion.abstractor_suggestion_sources.destroy_all
          abstractor_suggestion.abstractor_suggestion_object_value.destroy
          abstractor_suggestion.destroy
        end
        abstractor_abstraction.destroy
      end
    end
  end
end