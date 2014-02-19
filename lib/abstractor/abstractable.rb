module Abstractor
  module Abstractable
    def self.included(base)
      base.class_eval do
        has_many :abstractions, class_name: Abstractor::Abstraction, as: :subject

        has_many :abstraction_groups, class_name: Abstractor::AbstractionGroup, as: :subject

        accepts_nested_attributes_for :abstractions, allow_destroy: false

        def self.by_suggestion_status(suggestion_status)
          suggestion_status_needs_review = Abstractor::SuggestionStatus.where(:name => 'Needs review').first
          suggestion_status_accepted= Abstractor::SuggestionStatus.where(:name => 'Accepted').first
          suggestion_status_rejected = Abstractor::SuggestionStatus.where(:name => 'Rejected').first

          case suggestion_status
          when 'needs_review'
            where(["EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstraction_id AND aas.suggestion_status_id = ? WHERE #{self.table_name}.id = aa.subject_id)", suggestion_status_needs_review])
          when 'reviewed'
            where(["EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstraction_id WHERE #{self.table_name}.id = aa.subject_id) AND NOT EXISTS (SELECT 1 FROM abstractor_subjects asb JOIN abstractor_abstractions aa ON asb.id = aa.abstractor_subject_id AND asb.subject_type = '#{self.to_s}' JOIN abstractor_suggestions aas ON aa.id = aas.abstraction_id  AND aas.suggestion_status_id = ? WHERE #{self.table_name}.id = aa.subject_id)", suggestion_status_needs_review])
          else
            where(nil)
          end
        end

        def self.subjects
          Abstractor::Subject.where(subject_type: self.to_s)
        end

        def self.abstraction_schemas
          subjects.map(&:abstraction_schema)
        end

        def self.subject_groups
          subjects.map(&:subject_group).uniq
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
      self.class.subjects.each do |subject|
        subject.abstract(self)
      end
    end

    def detect_abstraction(abstraction_schema)
      abstractions(true).detect { |abstraction| abstraction.abstractor_subject.abstraction_schema == abstraction_schema }
    end

    def find_or_create_abstraction(abstraction_schema, abstractor_subject)
      if abstraction = detect_abstraction(abstraction_schema)
      else
        abstraction = Abstractor::Abstraction.create!(abstractor_subject: abstractor_subject, subject: self)
        if abstractor_subject.groupable?
          abstraction_group = find_or_create_abstraction_group(abstractor_subject.subject_group)
          abstraction_group.abstractions << abstraction
        end
      end
      abstraction
    end

    def detect_abstraction_group(subject_group)
      abstraction_groups(true).detect { |abstraction_group| abstraction_group.subject_group ==  subject_group }
    end

    def find_or_create_abstraction_group(subject_group)
      if abstraction_group = detect_abstraction_group(subject_group)
      else
        abstraction_group = Abstractor::AbstractionGroup.create(subject_group: subject_group, subject: self)
      end
      abstraction_group
    end

    def abstractions_by_suggestion_status(suggestion_statuses)
      abstractions.map(&:suggestions).flatten.select { |as| Array.new(suggestion_statuses).any? { |suggestion_status| as.suggestion_status == suggestion_status } }
    end

    def remove_abstractions
      abstractions.each do |abstraction|
        abstraction.suggestions.each do |suggestion|
          suggestion.suggestion_sources.destroy_all
          suggestion.suggestion_object_value.destroy
          suggestion.destroy
        end
        abstraction.destroy
      end
    end
  end
end