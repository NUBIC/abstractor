module Abstractor
  module Abstractable
    # @!parse include Abstractor::Abstractable::InstanceMethods
    # @!parse extend Abstractor::Abstractable::ClassMethods
    def self.included(base)
      base.class_eval do
        has_many :abstractor_abstractions, class_name: Abstractor::AbstractorAbstraction, as: :about

        has_many :abstractor_abstraction_groups, class_name: Abstractor::AbstractorAbstractionGroup, as: :about

        accepts_nested_attributes_for :abstractor_abstractions, allow_destroy: false
      end
      base.send(:include, InstanceMethods)
      base.extend(ClassMethods)
    end

    module InstanceMethods
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

      ##
      # Returns all abstraction for the abstractable entity by abstractor_abstraction_status:
      #
      # * 'needs_review': Filter abstractions without a determined value (value, unknown or not_applicable).
      # * 'reviewed': Filter abstractions having a determined value (value, unknown or not_applicable).
      #
      # @param [String] abstractor_abstraction_status Filter abstractions that need review or are reviews.
      # @return [ActiveRecord::Relation] List of [Abstractor::AbstractorAbstraction].
      def abstractor_abstractions_by_abstractor_abstraction_status(abstractor_abstraction_status)
        case abstractor_abstraction_status
        when 'needs_review'
          abstractor_abstractions.not_deleted.select { |abstractor_abstraction| abstractor_abstraction.value.blank? && abstractor_abstraction.unknown.blank? && abstractor_abstraction.not_applicable.blank? }
        when 'reviewed'
          abstractor_abstractions.not_deleted.select { |abstractor_abstraction| !abstractor_abstraction.value.blank? || !abstractor_abstraction.unknown.blank? || !abstractor_abstraction.not_applicable.blank? }
        end
      end

      ##
      # Removes all abstractions, suggestions and indirect sources for the abstractable entity.  Optionally filtred to only 'unreviewd' abstractions.
      #
      # @param [Boolean] only_unreviewed Instructs whther to confine removal to only 'unreviewd' abstractions.
      # @return [void]
      def remove_abstractions(only_unreviewed = true)
        abstractor_abstractions.each do |abstractor_abstraction|
          if !only_unreviewed || (only_unreviewed && abstractor_abstraction.unreviewed?)
            abstractor_abstraction.abstractor_suggestions.each do |abstractor_suggestion|
              abstractor_suggestion.abstractor_suggestion_sources.destroy_all
              abstractor_suggestion.abstractor_suggestion_object_value.destroy if abstractor_suggestion.abstractor_suggestion_object_value
              abstractor_suggestion.destroy
            end
            abstractor_abstraction.abstractor_indirect_sources.each do |abstractor_indirect_source|
              abstractor_indirect_source.destroy
            end
            abstractor_abstraction.destroy
          end
        end
      end
    end

    module ClassMethods
      ##
      # Returns all abstractable entities filtered by the parameter abstractor_abstraction_status:
      #
      # * 'needs_review': Filter abstractable entites having at least one abstraction without a determined value (value, unknown or not_applicable).
      # * 'reviewed': Filter abstractable entites having no abstractions without a determined value (value, unknown or not_applicable).
      #
      # @param [String] abstractor_abstraction_status Filter abstactable entities that an abstraction that 'needs_review' or are all abstractions are 'reviewed'.
      # @return [ActiveRecord::Relation] List of abstractable entities.
      def by_abstractor_abstraction_status(abstractor_abstraction_status)
        case abstractor_abstraction_status
        when 'needs_review'
          where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND (aa.value IS NULL OR aa.value = '') AND (aa.unknown IS NULL OR aa.unknown = ?) AND (aa.not_applicable IS NULL OR aa.not_applicable = ?))", false, false])
        when 'reviewed'
          where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id) AND NOT EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND COALESCE(aa.value, '') = '' AND COALESCE(aa.unknown, ?) != ? AND COALESCE(aa.not_applicable, ?) != ?)", false, true, false, true])
        else
          where(nil)
        end
      end

      ##
      # Returns the abstractor subjects associated with the abstractable entity.
      #
      # By default, the method will return all abstractor subjects.
      #
      # @param [Hash] options the options to filter the objects returned
      # @option options [Boolean] :grouped Filters the list of Abstactor::AbstractorSubject objects to grouped and non-grouped.  Defaults to nil which returns all objects.
      # @return ActiveRecord::Relation list of Abstactor::AbstractorSubject objects
      def abstractor_subjects(options = {})
        options = { grouped: nil }.merge(options)
        subjects = Abstractor::AbstractorSubject.where(subject_type: self.to_s)
        subjects = case options[:grouped]
        when true
          subjects.select{ |s| s.abstractor_subject_group_member}
        when false
          subjects.reject{ |s| s.abstractor_subject_group_member}
        when nil
          subjects
        end
        subjects
      end

      ##
      # Returns the abstractor abstraction schemas associated with the abstractable entity.
      #
      # By default, the method will return all abstractor abstraction schemas.
      #
      # @param [Hash] options the options to filter the objects returned
      # @option options [Boolean] :grouped Filters the list of Abstractor::AbstractorAbstractionSchema objects to grouped and non-grouped.  Defaults to nil which returns all objects.
      # @return ActiveRecord::Relation list of Abstactor::AbstractorAbstractionSchema objects
      def abstractor_abstraction_schemas(options= {})
        options = { grouped: nil }.merge(options)
        abstractor_subjects(options).map(&:abstractor_abstraction_schema)
      end

      def abstractor_subject_groups
        abstractor_subjects.map(&:abstractor_subject_group).compact.uniq
      end

      ##
      # Pivot abstractions to simulate regular columns on an abstractable entity.
      #
      # Example: an ActiveRecod model PathologyCaseReport with the columns
      # * 'collection_date'
      # * 'report_text'
      # And the abstraction 'has_cancer_diagnosis'.
      #
      # This method allows for the querying of the pathology_cases table as if
      # it was strucutred like so:
      # 'select id, collection_date, report_text, has_cancer_diagnosis from pathology_cases'
      #
      # @return ActiveRecord::Relation
      def pivot_abstractions
        select = prepare_pivot_select(grouped: false)
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        j = case adapter
        when 'sqlite3'
          prepare_pivot_joins(select, "'t'")
        when 'sqlserver'
          prepare_pivot_joins(select, '1')
        when 'postgresql'
          prepare_pivot_joins(select, 'true')
        end
        joins(j).select("#{self.table_name}.*, pivoted_abstractions.*")
      end

      ##
      # Pivot grouped abstractions to simulate regular columns on an abstractable entity.
      #
      # Example: an ActiveRecod model RadationTreatment with the columns
      # * 'treatment_date'
      # * 'total_dose'
      # And the abstractions grouped together with the name 'has_treatment_target':
      # * 'has_anatomical_location'.
      # * 'has_laterality'
      #
      # This method allows for the querying of the radiation_treatments table as if
      # it was strucutred like so:
      # 'select id, treatment_date, toatl_dose, has_anatomical_location, has_laterality from radiation_treatments'
      #
      # If an abstractable entity has multiple instances of grouped abstractions the entity will be returned mutlple times.
      #
      # @param [String] abstractor_subject_groups_name name of {Abstractor::Methods::Models:AbtractorSubjectGroup}
      # @return ActiveRecord::Relation
      # @see Abstractor::Methods::Models:AbstractorSubjectGroup
      def pivot_grouped_abstractions(abstractor_subject_groups_name)
        select = prepare_pivot_select(grouped: true)
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        j = case adapter
        when 'sqlite3'
          prepare_grouped_pivot_joins(select, "'t'", abstractor_subject_groups_name)
        when 'sqlserver'
          prepare_grouped_pivot_joins(select, '1', abstractor_subject_groups_name)
        when 'postgresql'
          prepare_grouped_pivot_joins(select, 'true', abstractor_subject_groups_name)
        end
        joins(j).select("#{self.table_name}.*, pivoted_abstractions.*")
      end

      private

        def prepare_pivot_select(options= {})
          options.reverse_merge!({ grouped: nil })
          options = { grouped: nil }.merge(options)
          select =[]
          abstractor_abstraction_schemas(options).map(&:predicate).each do |predicate|
            select << "MAX(CASE WHEN data.predicate = '#{predicate}' THEN data.value ELSE NULL END) AS #{predicate}"
          end
          select = select.join(',')
        end

        def prepare_pivot_joins(select, bool)
          "LEFT JOIN
          (
          SELECT #{self.table_name}.id AS subject_id,
          #{select}
          FROM
          (SELECT   aas.predicate
                  , aas.id AS abstractor_abstraction_schema_id
                  , asb.subject_type
                  , aa.about_id
                  , CASE WHEN aa.value IS NOT NULL AND aa.value != '' THEN aa.value WHEN aa.unknown = #{bool} THEN 'unknown' WHEN aa.not_applicable = #{bool} THEN 'not applicable' END AS value
          FROM abstractor_abstractions aa JOIN abstractor_subjects asb            ON aa.abstractor_subject_id = asb.id
                                          JOIN abstractor_abstraction_schemas aas ON asb.abstractor_abstraction_schema_id = aas.id
          WHERE asb.subject_type = '#{self.to_s}'
          AND NOT EXISTS (
            SELECT 1
            FROM abstractor_abstraction_group_members aagm
            WHERE aa.id = aagm.abstractor_abstraction_id
          )
          ) data join #{self.table_name} ON  data.about_id = #{self.table_name}.id
          GROUP BY #{self.table_name}.id
          ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
          "
        end

        def prepare_grouped_pivot_joins(select, bool, abstractor_subject_groups_name)
          abstractor_subject_group = abstractor_subject_groups.detect { |abstractor_subject_group| abstractor_subject_group.name ==  abstractor_subject_groups_name }

          "JOIN
           (
           SELECT #{self.table_name}.id AS subject_id,
           #{select}
           FROM
           (SELECT   aas.predicate
                   , aas.id AS abstraction_schema_id
                   , asb.subject_type
                   , aa.about_id
                   , CASE WHEN aa.value IS NOT NULL AND aa.value != '' THEN aa.value WHEN aa.unknown = #{bool} THEN 'unknown' WHEN aa.not_applicable = #{bool} THEN 'not applicable' END AS value
                   , aag.id AS abstractor_abstraction_group_id
           FROM abstractor_abstractions aa JOIN abstractor_subjects asb                    ON aa.abstractor_subject_id = asb.id
                                           JOIN abstractor_abstraction_schemas aas         ON asb.abstractor_abstraction_schema_id = aas.id
                                           JOIN abstractor_abstraction_group_members aagm  ON aa.id = aagm.abstractor_abstraction_id
                                           JOIN abstractor_abstraction_groups aag          ON aagm.abstractor_abstraction_group_id= aag.id
           WHERE asb.subject_type = '#{self.to_s}'
           AND aag.abstractor_subject_group_id = #{abstractor_subject_group.id}
           ) data join #{self.table_name} ON  data.about_id = #{self.table_name}.id
           GROUP BY #{self.table_name}.id, abstractor_abstraction_group_id
           ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
           "
        end
    end
  end
end