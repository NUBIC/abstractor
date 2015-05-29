require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Abstractor::AbstractorAbstractionSchemasController, :type => :request do
  let(:accept_json) { { "Accept" => "application/json" } }
  let(:json_content_type) { { "Content-Type" => "application/json" } }
  let(:accept_and_return_json) { accept_json.merge(json_content_type) }

  before(:each) do
    Abstractor::Setup.system
  end

  describe "GET /abstractor_abstraction_schemas/:id" do
    it "returns an abstraction schema", focus: false do
      abstractor_object_type = Abstractor::AbstractorObjectType.where(value: Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST).first
      abstractor_abstraction_schema = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
      abstractor_abstraction_schema.abstractor_abstraction_schema_predicate_variants << FactoryGirl.build(:abstractor_abstraction_schema_predicate_variant, value: 'smoperty')
      abstractor_abstraction_schema.abstractor_object_values << FactoryGirl.build(:abstractor_object_value, value: 'foo', properties: '{  "type":"Rpt", "select_for":"Brain, CNS, and Pituitary" }', vocabulary_code: '8148/0', vocabulary: 'ICD-O-3', vocabulary_version: '2011 Updates to ICD-O-3')
      FactoryGirl.create(:abstractor_object_value_variant, abstractor_object_value: abstractor_abstraction_schema.abstractor_object_values.first, value: 'boo')

      get "/abstractor_abstraction_schemas/#{abstractor_abstraction_schema.id}", {}, accept_json

      expect(response.status).to be 200

      body = JSON.parse(response.body)
      puts body
      expect(body['abstractor_abstraction_schema']['predicate']).to eq 'has_some_property'
      expect(body['abstractor_abstraction_schema']['display_name']).to eq 'some_property'
      expect(body['abstractor_abstraction_schema']['abstractor_object_type']).to eq Abstractor::Enum::ABSTRACTOR_OBJECT_TYPE_LIST
      expect(body['abstractor_abstraction_schema']['preferred_name']).to eq 'property'
      expect(body['abstractor_abstraction_schema']['predicate_variants']).to eq  [{ 'value' => 'smoperty' }]
      expect(body['abstractor_abstraction_schema']['object_values']).to eq  [{"value"=>"foo", "properties" => {"type"=>"Rpt", "select_for"=>"Brain, CNS, and Pituitary"}, "vocabulary_code"=>"8148/0", "vocabulary"=>"ICD-O-3", "vocabulary_version"=>"2011 Updates to ICD-O-3", "object_value_variants"=>[{"value"=>"boo"}]}]
    end
  end
end