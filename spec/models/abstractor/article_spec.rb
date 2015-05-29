require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Article do
  before(:each) do
    Abstractor::Setup.system
    list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
    v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    @favorite_baseball_team_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_baseball_team', display_name: 'Favorite baseball team', abstractor_object_type: list_object_type, preferred_name: 'Favorite baseball team')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema)
    abstractor_object_values = []
    abstractor_object_value = nil
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'White Sox')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Cubs')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Twins')
    abstractor_object_value.save
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
  end

  describe "querying by abstractor suggestion type" do
    it 'can report what has an unknown suggestion type', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
    end

    it 'reports empty what has a unknown suggestion type when there is a not unknown suggestion', focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to be_empty
    end

    it 'can report what has a not unknown suggestion type', focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED)).to eq([article])
    end

    it 'reports empty what has a not unknown suggestion type when there is an unknown suggestion', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED)).to be_empty
    end
  end

  describe "querying by abstractor suggestion type (filtered)" do
    before(:each) do
      list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
      unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
      @abstractor_abstraction_schema_always_unknown = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: list_object_type, preferred_name: 'Always unknown')
      @abstractor_subject_abstraction_schema_always_unknown = Abstractor::AbstractorSubject.create(:subject_type => 'Article', :abstractor_abstraction_schema => @abstractor_abstraction_schema_always_unknown)
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_abstraction_schema_always_unknown, from_method: 'note_text', abstractor_abstraction_source_type: source_type_nlp_suggestion, :abstractor_rule_type => unknown_rule)
    end

    it 'can report what has an unknown suggestion type', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'reports empty what has a unknown suggestion type when there is a not unknown suggestion', focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'can report what has a not unknown suggestion type', focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it 'reports empty what has a not unknown suggestion type when there is an unknown suggestion', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end
  end

  describe "querying by abstractor suggestion (namespaced)" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
      v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @favorite_philosopher_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_philosopher', display_name: 'Favorite philosopher', abstractor_object_type: list_object_type, preferred_name: 'Favorite philosopher')
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
      abstractor_object_values = []
      abstractor_object_value = nil
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Rorty')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Wittgenstein')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Dennet')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    end

    it 'can report what has an unknown suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1)).to eq([article])
    end

    it 'reports empty what has a unknown suggestion type when there is a not unknown suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1)).to be_empty
    end

    it 'can report what has a not unknown suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1)).to eq([article])
    end

    it 'reports empty what has a not unknown suggestion type when there is an unknown suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1)).to be_empty
    end
  end

  describe "querying by abstractor suggestion (namespaced) (filtered)" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
      v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
      unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @favorite_philosopher_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_philosopher', display_name: 'Favorite philosopher', abstractor_object_type: list_object_type, preferred_name: 'Favorite philosopher')
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
      abstractor_object_values = []
      abstractor_object_value = nil
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Rorty')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Wittgenstein')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      abstractor_object_values << abstractor_object_value = Abstractor::AbstractorObjectValue.create(value: 'Dennet')
      abstractor_object_value.save
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: abstractor_object_value)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
      @abstractor_abstraction_schema_always_unknown = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: list_object_type, preferred_name: 'Always unknown')
      @abstractor_subject_abstraction_schema_always_unknown = Abstractor::AbstractorSubject.create(:subject_type => 'Article', :abstractor_abstraction_schema => @abstractor_abstraction_schema_always_unknown, namespace_type: 'Discerner::Search', namespace_id: 1)
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_abstraction_schema_always_unknown, from_method: 'note_text', abstractor_abstraction_source_type: source_type_nlp_suggestion, :abstractor_rule_type => unknown_rule)
    end

    it 'can report what has an unknown suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'reports empty what has a unknown suggestion type when there is a not unknown suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'can report what has a not unknown suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it 'reports empty what has a not unknown suggestion type when there is an unknown suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end
  end
end