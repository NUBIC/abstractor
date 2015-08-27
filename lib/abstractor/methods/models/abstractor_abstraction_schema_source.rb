module Abstractor
  module Methods
    module Models
      module AbstractorAbstractionSchemaSource
        def self.included(base)
          base.send :include, SoftDelete
          base.send(:include, InstanceMethods)
          base.send :has_many, :abstractor_abstraction_schema_source_variants
          base.send :validates_presence_of, [:name, :about_type, :custom_nlp_provider, :from_method]

        end

        module InstanceMethods
          ##
          # Creates or finds an instance of an Abstractor::AbstractorAbstractionSchemaSource.
          # The method will send data returned by the from_method on the the abstractable entity passed via the about parameter
          # to the external source specified by custom_nlp_provider. Data returned by the external source will be used to create
          # instances of Abstractor::AbstractorAbstractionSchema, Abstractor::AbstractorSubject, Abstractor::AbstractorAbstractionSource,
          # AbstractorSubjectGroup, AbstractorSubjectGroupMember, AbstractorAbstraction, AbstractorSuggestion and AbstractorSuggestionSource
          # for the abstractable entity passed via the about parameter.
          #
          # @param [ActiveRecord::Base] about The entity to abstract.  An instance of the class specified in the Abstractor::AbstractorAbstractionSchemaSource#about_type attribute.
          # @return [void]
          def abstract(about)
            suggestion_endpoint = CustomNlpProvider.determine_suggestion_endpoint(custom_nlp_provider)
            unless from_method.blank?
              abstractor_text = about.send(from_method)
              body = Abstractor::CustomNlpProvider.format_body_for_abstraction_schema_endpoint(self, abstractor_abstraction_schema_source_variants.map(&:name), about, abstractor_text)
              HTTParty.post(suggestion_endpoint, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
            end
          end

          def configure_and_store_abstractions(params)
            if params[:about_type].blank? || params[:about_id].blank?
              self.errors[:base] << '[:about_type] and params[:about_id] can\'t be blank'
            else
              about = params[:about_type].safe_constantize.find(params[:about_id])
              source = params[:source]
              params[:result].each_with_index do |result, i|
                abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: "galaxy_#{i}").first_or_create
                result[:galaxy].each do |key|
                  parse_key(key_hash: key, abstractor_subject_group: abstractor_subject_group, about: about, source: source)
                end
              end
            end
          end

          # {
          #     universe_id: 1,
          #     about_type: 'Moomin',
          #     about_id: 1,
          #     source: 'lui_papis_nlp',
          #     result: [{
          #         galaxy: [{
          #             key: 'key1',
          #             value: 'value1',
          #             origin: 'original_key_value',
          #             key_score: 'key_score',
          #             value_score: 'value_score',
          #             sub_keys: [{
          #                 key: 'subkey1',
          #                 value: 'subvalue1',
          #                 origin: 'suborigin1',
          #                 key_score: 'subkey_score',
          #                 value_score: 'subvalue_score',
          #                 sub_keys: []
          #             }]
          #         }]
          #     }]
          # }
          private
            def parse_key(params)
              if params[:key_hash].blank? || params[:about].blank? || params[:source].blank?
                self.errors[:base] << "[:key_hash], [:about], [:source] can't be blank: #{params}"
              elsif
                params[:key_hash]['key'].blank? || params[:key_hash]['value'].blank? || params[:key_hash]['origin'].blank?
                self.errors[:base] << "key, value, origin can't be blank: #{params[:key_hash]}"
              else
                display_name = params[:key_hash]['key']
                display_name.insert(0, params[:parent_abstractor_abstraction_schema].display_name + ': ') if params[:parent_abstractor_abstraction_schema]

                ## Set up configuration
                abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
                  predicate:              params[:key_hash]['key'],
                  display_name:           display_name,
                  abstractor_object_type: Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_STRING).first,
                  preferred_name:         params[:key_hash]['key']
                ).first_or_create
                abstractor_object_value = Abstractor::AbstractorObjectValue.where(value: params[:key_hash]['value']).first_or_create
                Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create

                abstractor_subject = Abstractor::AbstractorSubject.where(
                  subject_type: params[:about].class,
                  abstractor_abstraction_schema: abstractor_abstraction_schema,
                  namespace_type: namespace_type,
                  namespace_id: namespace_id
                ).first_or_create

                abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.where(
                  abstractor_subject: abstractor_subject,
                  from_method: from_method,
                  abstractor_rule_type_id: Abstractor::AbstractorRuleType.where(name: Abstractor::Enum::ABSTRACTOR_RULE_TYPE_NAME_VALUE).first.id,
                  abstractor_abstraction_source_type_id: Abstractor::AbstractorAbstractionSourceType.where(name: Abstractor::Enum::ABSTRACTOR_ABSTRACTION_SOURCE_TYPE_CUSTOM_NLP_SCHEMA).first.id,
                  custom_nlp_provider: params[:source]
                ).first_or_create

                if params[:abstractor_subject_group]
                  Abstractor::AbstractorSubjectGroupMember.where(
                    abstractor_subject: abstractor_subject,
                    abstractor_subject_group: params[:abstractor_subject_group]
                  ).first_or_create
                end

                ## Set up abstractions
                abstractor_abstraction = params[:about].find_or_create_abstractor_abstraction(abstractor_abstraction_schema, abstractor_subject)
                abstractor_subject.suggest(abstractor_abstraction, abstractor_abstraction_source, params[:key_hash]['origin'], params[:key_hash]['origin'], params[:about].id, params[:about].class, from_method, nil,params[:key_hash]['value'], nil, nil, nil, nil)

                if params[:key_hash]['sub_keys']
                  params[:key_hash]['sub_keys'].each do |sub_key|
                    parse_key(key_hash: sub_key, abstractor_subject_group: params[:abstractor_subject_group], about: params[:about], source: params[:source], parent_abstractor_abstraction_schema: abstractor_abstraction_schema)
                  end
                end
              end
            end
        end
      end
    end
  end
end
