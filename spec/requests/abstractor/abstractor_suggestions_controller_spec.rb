require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Abstractor::AbstractorSuggestionsController, :type => :request do
  let(:accept_json) { { "Accept" => "application/json" } }
  let(:json_content_type) { { "Content-Type" => "application/json" } }
  let(:accept_and_return_json) { accept_json.merge(json_content_type) }

  describe "POST /abstractor_abstractions/:abstractor_abstraction_id/abstractor_suggestions" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      custom_nlp_suggestion_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom nlp suggestion').first
      abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
        predicate: 'has_cancer_histology',
        display_name: 'Cancer Histology',
        abstractor_object_type: list_object_type,
        preferred_name: 'cancer histology').first_or_create

      histologies =  [{ name: 'glioblastoma, nos', icdo3_code: '9440/3' }, { name: 'meningioma, nos', icdo3_code: '9530/0' }]
      histologies.each do |histology|
        abstractor_object_value = Abstractor::AbstractorObjectValue.create(:value => "#{histology[:name]} (#{histology[:icdo3_code]})")
        Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create
        Abstractor::AbstractorObjectValueVariant.create(:abstractor_object_value => abstractor_object_value, :value => histology[:name])
        histology_synonyms = [{ synonym_name: 'glioblastoma', icdo3_code: '9440/3' }, { synonym_name: 'spongioblastoma multiforme', icdo3_code: '9440/3' }, { synonym_name: 'gbm', icdo3_code: '9440/3' }, { synonym_name: 'meningioma', icdo3_code: '9530/0' }, { synonym_name: 'leptomeningioma', icdo3_code: '9530/0' }, { synonym_name: 'meningeal fibroblastoma', icdo3_code: '9530/0' }]
        histology_synonyms.select { |histology_synonym| histology.to_hash[:icdo3_code] == histology_synonym.to_hash[:icdo3_code] }.each do |histology_synonym|
          Abstractor::AbstractorObjectValueVariant.create(:abstractor_object_value => abstractor_object_value, :value => histology_synonym[:synonym_name])
        end
      end

      abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'PathologyCase', :abstractor_abstraction_schema => abstractor_abstraction_schema)
      @from_method = 'note_text'
      @abstractor_abstraction_source = Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: @from_method, abstractor_abstraction_source_type: custom_nlp_suggestion_source_type, custom_nlp_provider: 'custom_nlp_provider_name')
      @abstractor_abstraction_schema_has_cancer_histology = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_cancer_histology').first
      @abstractor_subject_abstraction_schema_has_cancer_histology = Abstractor::AbstractorSubject.where(subject_type: PathologyCase.to_s, abstractor_abstraction_schema_id:@abstractor_abstraction_schema_has_cancer_histology.id).first
      stub_request(:post, "http://custom-nlp-provider.test/suggest").to_return(:status => 200, :body => "", :headers => {})
      text = "The patient has a diagnosis of glioblastoma.  GBM does not have a good prognosis.  But I can't rule out meningioma."
      @pathology_case = FactoryGirl.create(:pathology_case, note_text: text, patient_id: 1)
      @pathology_case.abstract
      @abstractor_abstraciton = @pathology_case.reload.abstractor_abstractions.first
    end

    it "creates a suggestion", focus: false do
      abstractor_suggestion =  { abstractor_suggestion:
        {
          abstractor_abstraction_source_id: @abstractor_abstraction_source.id,
          source_id: @pathology_case.id,
          source_type:@pathology_case.class.to_s,
          source_method: @from_method,
          value: "glioblastoma",
          unknown: nil,
          not_applicable: nil,
          suggestion_sources:[
                      {
                      match_value: "glioblastoma",
                      sentence_match_value: "The patient has a diagnosis of glioblastoma."
                   },
                   {
                      match_value: "gbm",
                      sentence_match_value: "GBM does not have a good prognosis."
                   }
                ]
        }
      }

      post "/abstractor_abstractions/#{@abstractor_abstraciton.id}/abstractor_suggestions", abstractor_suggestion.to_json, accept_and_return_json
      expect(response.status).to eq 201
      expect(@abstractor_abstraciton.reload.abstractor_suggestions.first.suggested_value).to eq('glioblastoma')
      expect(@abstractor_abstraciton.reload.abstractor_suggestions.first.abstractor_suggestion_sources.map(&:match_value)).to match_array(["glioblastoma", "gbm"])
      expect(@abstractor_abstraciton.reload.abstractor_suggestions.first.abstractor_suggestion_sources.map(&:sentence_match_value)).to match_array(["GBM does not have a good prognosis.", "The patient has a diagnosis of glioblastoma."])
    end

    it 'returns an error status code if and invalid body is posted', focus: false do
      abstractor_suggestion =  { moomin: 'little my' }

      post "/abstractor_abstractions/#{@abstractor_abstraciton.id}/abstractor_suggestions", abstractor_suggestion.to_json, accept_and_return_json
      expect(response.status).to eq 422
    end
  end
end