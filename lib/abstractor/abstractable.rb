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
      ##
      # Returns all abstractions for the abstractable entity by a namespace.
      #
      # @param [Hash] options the options to filter the list of abstractions to a namespace.
      # @option options [String] :namespace_type The type parameter of the namespace.
      # @option options [Integer] :namespace_id The instance parameter of the namespace.
      # @return [ActiveRecord::Relation] List of [Abstractor::AbstractorAbstraction].
      def abstractor_abstractions_by_namespace(options = {})
        options = { namespace_type: nil, namespace_id: nil }.merge(options)
        if options[:namespace_type] || options[:namespace_id]
          abstractor_abstractions.not_deleted.where(abstractor_subject_id: self.class.abstractor_subjects(options).map(&:id))
        else
          abstractor_abstractions.not_deleted
        end
      end
      ##
      # Returns all abstraction groups for the abstractable entity by a namespace.
      #
      # @param [Hash] options the options to filter the list of abstraction groups to a namespace.
      # @option options [String] :namespace_type The type parameter of the namespace.
      # @option options [Integer] :namespace_id The instance parameter of the namespace.
      # @return [ActiveRecord::Relation] List of [Abstractor::AbstractorAbstractionGroup].
      def abstractor_abstraction_groups_by_namespace(options = {})
        options = { namespace_type: nil, namespace_id: nil }.merge(options)
        if options[:namespace_type] || options[:namespace_id]
          abstractor_abstractions_by_namespace(options).map(&:abstractor_abstraction_group).compact.uniq
        else
          abstractor_abstraction_groups.not_deleted
        end
      end

      ##
      # The method for generating abstractions from the abstractable entity.
      #
      # The generation of abstactions is based on the setup of Abstactor::AbstractorAbstactionSchema,
      # Abstractor::AbstractorSubject, Abstractor::AbstractorSubjectGroup and Abstractor::AbstractorAbstractionSource associated to the abstractable entity.
      #
      # Namespacing allows for different sets data points to be associated to the same abstractable entity.
      #
      # Namespacing is achieved by setting the Abstractor::AbstractorSubject#namespace_type and Abstractor::AbstractorSubject#namespace_id attributes.
      #
      # Passing a namespace to this method will restrict the generation of abstractions to the given namespace. Otherwise, all configured abstractions associated to the abstractable entity will be generated.
      #
      # A practical example of the use of a namespace would be two different clincal departments wanting to chart abstract two distinct sets of datapoints for progress notes extracted from an electronic medical record system.
      # @param [Hash] options the options to filter the generation of abstractions to a namespace.
      # @option options [String] :namespace_type The type parameter of the namespace.
      # @option options [Integer] :namespace_id The instance parameter of the namespace.
      # @return [void]
      def abstract(options = {})
        options = { namespace_type: nil, namespace_id: nil }.merge(options)
        self.class.abstractor_subjects(options).each do |abstractor_subject|
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
      # @param [Hash] options the options to filter abstractions to a namespace.
      # @option options [String] :namespace_type the type parameter of the namespace.
      # @option options [Integer] :namespace_id the instance parameter of the namespace.
      # @return [ActiveRecord::Relation] list of [Abstractor::AbstractorAbstraction].
      def abstractor_abstractions_by_abstractor_abstraction_status(abstractor_abstraction_status, options = {})
        options = { namespace_type: nil, namespace_id: nil }.merge(options)
        case abstractor_abstraction_status
        when Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW
          abstractor_abstractions_by_namespace(options).select { |abstractor_abstraction| abstractor_abstraction.value.blank? && abstractor_abstraction.unknown.blank? && abstractor_abstraction.not_applicable.blank? }
        when Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED
          abstractor_abstractions_by_namespace(options).select { |abstractor_abstraction| !abstractor_abstraction.value.blank? || !abstractor_abstraction.unknown.blank? || !abstractor_abstraction.not_applicable.blank? }
        end
      end

      ##
      # Removes all abstractions, suggestions and indirect sources for the abstractable entity.  Optionally filtred to only 'unreviewed' abstractions and to a given namespace.
      #
      # @param [Hash] options the options to filter the removal of abstractions.
      # @option options [Booelan] :only_unreviewed Instructs whether to confine removal to only 'unreviewed' abstractions.
      # @option options [String] :namespace_type The type parameter of the namespace to remove.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to remove.
      # @return [void]
      def remove_abstractions(options = {})
        options = { only_unreviewed: true, namespace_type: nil, namespace_id: nil }.merge(options)
        abstractor_abstractions_by_namespace(options).each do |abstractor_abstraction|
          if !options[:only_unreviewed] || (options[:only_unreviewed] && abstractor_abstraction.unreviewed?)
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
      # @param [Hash] options the options to filter the entities returned.
      # @option options [String] :namespace_type The type parameter of the namespace to filter the entities.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to filter the entities.
      # @return [ActiveRecord::Relation] List of abstractable entities.
      def by_abstractor_abstraction_status(abstractor_abstraction_status, options = {})
        options = { namespace_type: nil, namespace_id: nil }.merge(options)

        if options[:namespace_type] || options[:namespace_id]
          case abstractor_abstraction_status
          when Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW
            where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = ? AND sub.namespace_id = ? WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND (aa.value IS NULL OR aa.value = '') AND (aa.unknown IS NULL OR aa.unknown = ?) AND (aa.not_applicable IS NULL OR aa.not_applicable = ?))", options[:namespace_type], options[:namespace_id], false, false])
          when Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED
            where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = ? AND sub.namespace_id = ? WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id) AND NOT EXISTS (SELECT 1 FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = ? AND sub.namespace_id = ? WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND COALESCE(aa.value, '') = '' AND COALESCE(aa.unknown, ?) != ? AND COALESCE(aa.not_applicable, ?) != ?)", options[:namespace_type], options[:namespace_id], options[:namespace_type], options[:namespace_id], false, true, false, true])
          else
            where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa JOIN abstractor_subjects sub ON aa.abstractor_subject_id = sub.id AND sub.namespace_type = ? AND sub.namespace_id = ? WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id)", options[:namespace_type], options[:namespace_id]])
          end
        else
          case abstractor_abstraction_status
          when Abstractor::Enum::ABSTRACTION_STATUS_NEEDS_REVIEW
            where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND (aa.value IS NULL OR aa.value = '') AND (aa.unknown IS NULL OR aa.unknown = ?) AND (aa.not_applicable IS NULL OR aa.not_applicable = ?))", false, false])
          when Abstractor::Enum::ABSTRACTION_STATUS_REVIEWED
            where(["EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id) AND NOT EXISTS (SELECT 1 FROM abstractor_abstractions aa WHERE aa.deleted_at IS NULL AND aa.about_type = '#{self.to_s}' AND #{self.table_name}.id = aa.about_id AND COALESCE(aa.value, '') = '' AND COALESCE(aa.unknown, ?) != ? AND COALESCE(aa.not_applicable, ?) != ?)", false, true, false, true])
          else
            where(nil)
          end
        end
      end

      ##
      # Returns the abstractor subjects associated with the abstractable entity.
      #
      # By default, the method will return all abstractor subjects.
      #
      # @param [Hash] options the options to filter the subjects returned.
      # @option options [Boolean] :grouped Filters the list of Abstactor::AbstractorSubject objects to grouped and non-grouped.  Defaults to nil which returns all objects.
      # @option options [String] :namespace_type The type parameter of the namespace to filter the subjects.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to filter the subjects.
      # @return ActiveRecord::Relation list of Abstactor::AbstractorSubject objects
      def abstractor_subjects(options = {})
        options = { grouped: nil, namespace_type: nil, namespace_id: nil }.merge(options)
        subjects = Abstractor::AbstractorSubject.where(subject_type: self.to_s)
        if options[:namespace_type] || options[:namespace_id]
          subjects = subjects.select { |subject| subject.namespace_type == options[:namespace_type] && subject.namespace_id == options[:namespace_id] }
        end
        subjects = case options[:grouped]
        when true
          subjects.select{ |s| s.abstractor_subject_group_member }
        when false
          subjects.reject{ |s| s.abstractor_subject_group_member }
        when nil
          subjects
        end
      end

      ##
      # Returns the abstractor abstraction schemas associated with the abstractable entity.
      #
      # By default, the method will return all abstractor abstraction schemas.
      #
      # @param [Hash] options the options to filter the abstaction schemas.
      # @option options [Boolean] :grouped Filters the list of Abstractor::AbstractorAbstractionSchema objects to grouped and non-grouped.  Defaults to nil which returns all abstraction schemas.
      # @option options [String] :namespace_type The type parameter of the namespace to filter the abstaction schemas.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to filter the abstaction schemas.
      # @return ActiveRecord::Relation list of Abstactor::AbstractorAbstractionSchema objects
      def abstractor_abstraction_schemas(options = {})
        options = { grouped: nil, namespace_type: nil, namespace_id: nil }.merge(options)
        abstractor_subjects(options).map(&:abstractor_abstraction_schema)
      end

      def abstractor_subject_groups(options = {})
        options = { grouped: true, namespace_type: nil, namespace_id: nil }.merge(options)
        abstractor_subjects(options).map(&:abstractor_subject_group).compact.uniq
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
      # @param [Hash] options the options to pivot the abstractions.
      # @option options [String] :namespace_type The type parameter of the namespace to pivot abstractions.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to pivot abstractions.
      # @return ActiveRecord::Relation
      def pivot_abstractions(options = {})
        options = { grouped: false, namespace_type: nil, namespace_id: nil }.merge(options)
        select = prepare_pivot_select(options)
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        j = case adapter
        when 'sqlite3'
          prepare_pivot_joins(select, "'t'", options)
        when 'sqlserver'
          prepare_pivot_joins(select, '1', options)
        when 'postgresql'
          prepare_pivot_joins(select, 'true', options)
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
      # @param [Hash] options the options to pivot the grouped abstractions.
      # @option options [String] :namespace_type The type parameter of the namespace to pivot grouped abstractions.
      # @option options [Integer] :namespace_id The instance parameter of the namespace to pivot grouped abstractions.
      # @return ActiveRecord::Relation
      # @see Abstractor::Methods::Models:AbstractorSubjectGroup
      def pivot_grouped_abstractions(abstractor_subject_groups_name, options = {})
        options = { grouped: true, namespace_type: nil, namespace_id: nil }.merge(options)
        select = prepare_pivot_select(options)
        adapter = ActiveRecord::Base.connection.instance_values["config"][:adapter]
        j = case adapter
        when 'sqlite3'
          prepare_grouped_pivot_joins(select, "'t'", abstractor_subject_groups_name, options)
        when 'sqlserver'
          prepare_grouped_pivot_joins(select, '1', abstractor_subject_groups_name, options)
        when 'postgresql'
          prepare_grouped_pivot_joins(select, 'true', abstractor_subject_groups_name, options)
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

        def prepare_pivot_joins(select, bool, options = {})
          if options[:namespace_type] || options[:namespace_id]
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
            AND asb.namespace_type = '#{options[:namespace_type]}'
            AND asb.namespace_id = #{options[:namespace_id]}
            AND NOT EXISTS (
              SELECT 1
              FROM abstractor_abstraction_group_members aagm
              WHERE aa.id = aagm.abstractor_abstraction_id
            )
            ) data join #{self.table_name} ON  data.about_id = #{self.table_name}.id
            GROUP BY #{self.table_name}.id
            ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
            "
          else
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
        end

        def prepare_grouped_pivot_joins(select, bool, abstractor_subject_groups_name, options = {})
          abstractor_subject_group = abstractor_subject_groups(options).detect { |abstractor_subject_group| abstractor_subject_group.name ==  abstractor_subject_groups_name }

          if options[:namespace_type] || options[:namespace_id]
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
             AND asb.namespace_type = '#{options[:namespace_type]}'
             AND asb.namespace_id = #{options[:namespace_id]}
             AND aag.abstractor_subject_group_id = #{abstractor_subject_group.id}
             ) data join #{self.table_name} ON  data.about_id = #{self.table_name}.id
             GROUP BY #{self.table_name}.id, abstractor_abstraction_group_id
             ) pivoted_abstractions ON pivoted_abstractions.subject_id = #{self.table_name}.id
             "
           else
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
end