require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Abstractor::AbstractorAbstractionSchemaSourcesController, :type => :request do
  let(:accept_json) { { "Accept" => "application/json" } }
  let(:json_content_type) { { "Content-Type" => "application/json" } }
  let(:accept_and_return_json) { accept_json.merge(json_content_type) }

  describe "POST /abstractor_abstraction_schema_sources/configure_and_store_abstractions.json" do
    before(:each) do
      Abstractor::Engine.routes.default_url_options[:host] = 'https://moomin.com'
      Abstractor::Setup.system
      @moomin = FactoryGirl.create(:moomin, note_text: 'hello, world')

      @abstractor_abstraction_schema_source = Abstractor::AbstractorAbstractionSchemaSource.where(
        name: 'external nlp schema',
        about_type: 'Moomin',
        namespace_type: 'Discener::Search',
        namespace_id: 1,
        custom_nlp_provider: 'custom_nlp_provider_name',
        from_method: 'note_text'
      ).first_or_create
    end

    it "sets up configuration and creates abstractions", focus: false do
      body = {
        universe_id: @abstractor_abstraction_schema_source.id,
        about_type: 'Moomin',
        about_id: 1,
        source: 'liu_papis_nlp',
        result: [{
          galaxy: [{
            key: 'key1',
            value: 'value1',
            origin: 'original_key_value',
            key_score: 'key_score',
            value_score: 'value_score',
            sub_keys: [{
              key: 'subkey1',
              value: 'subvalue1',
              origin: 'suborigin1',
              key_score: 'subkey_score',
              value_score: 'subvalue_score',
              sub_keys: []
            }]
          }]
        }]
      }

      post Abstractor::Engine.routes.url_helpers.configure_and_store_abstractions_abstractor_abstraction_schema_sources_url(format: :json), body.to_json, accept_and_return_json

      expect(response.status).to eq 200
      expect(@moomin.reload.class.abstractor_subjects.count).not_to eq(0)
      key1_subject = @moomin.class.abstractor_subjects.joins(:abstractor_abstraction_schema).where(abstractor_abstraction_schemas: { predicate: 'key1'}).first
      expect(key1_subject).not_to be_nil
      expect(key1_subject.abstractor_abstractions.length).to eq(1)
      expect(key1_subject.abstractor_abstractions.first.value).to be_nil
      expect(key1_subject.abstractor_abstractions.first.abstractor_suggestions.length).to eq(1)
      expect(key1_subject.abstractor_abstractions.first.abstractor_suggestions.first.suggested_value).to eq('value1')
      expect(key1_subject.abstractor_abstractions.first.abstractor_suggestions.first.abstractor_suggestion_sources.length).to eq(1)
      expect(key1_subject.abstractor_abstractions.first.abstractor_suggestions.first.abstractor_suggestion_sources.first.match_value).to eq('original_key_value')
    end
  end
end

