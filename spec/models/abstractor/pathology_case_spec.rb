require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe PathologyCase do
  before(:each) do
    Abstractor::Setup.system
    Setup.pathology_case
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    custom_nlp_suggestion_source_type = Abstractor::AbstractorAbstractionSourceType.where(name: 'custom nlp suggestion').first
    abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(
      predicate: 'has_cancer_histology',
      display_name: 'Cancer Histology',
      abstractor_object_type: list_object_type,
      preferred_name: 'cancer histology').first_or_create

    histologies =  [{ name: 'carcinoma in situ, nos', icdo3_code: '8010/2' }, { name: 'carcinoma, nos', icdo3_code: '8010/3' }, { name: 'carcinoma, metastatic, nos', icdo3_code: '8010/6' }]
    histologies.each do |histology|
      abstractor_object_value = Abstractor::AbstractorObjectValue.create(:value => "#{histology[:name]} (#{histology[:icdo3_code]})")
      Abstractor::AbstractorAbstractionSchemaObjectValue.where(abstractor_abstraction_schema: abstractor_abstraction_schema,abstractor_object_value: abstractor_object_value).first_or_create
      Abstractor::AbstractorObjectValueVariant.create(:abstractor_object_value => abstractor_object_value, :value => histology[:name])
      histology_synonyms = [{ synonym_name: 'intraepithelial carcinoma, nos', icdo3_code: '8010/2' }, { synonym_name: 'carcinoma in situ', icdo3_code: '8010/2' }, { synonym_name: 'intraepithelial carcinoma', icdo3_code: '8010/2' }, { synonym_name: 'carcinoma', icdo3_code: '8010/3' }, { synonym_name: 'malignant epithelial tumor', icdo3_code: '8010/3' }, { synonym_name: 'epithelial tumor malignant', icdo3_code: '8010/3' }, { synonym_name: 'secondary carcinoma', icdo3_code: '8010/6' }, { synonym_name: 'metastatic carcinoma', icdo3_code: '8010/6' }, { synonym_name: 'carcinoma metastatic', icdo3_code: '8010/6' }]
      histology_synonyms.select { |histology_synonym| histology.to_hash[:icdo3_code] == histology_synonym.to_hash[:icdo3_code] }.each do |histology_synonym|
        Abstractor::AbstractorObjectValueVariant.create(:abstractor_object_value => abstractor_object_value, :value => histology_synonym[:synonym_name])
      end
    end

    abstractor_subject = Abstractor::AbstractorSubject.create(:subject_type => 'PathologyCase', :abstractor_abstraction_schema => abstractor_abstraction_schema)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_abstraction_source_type: custom_nlp_suggestion_source_type, custom_nlp_provider:  'custom_nlp_provider_name')
    @abstractor_abstraction_schema_has_cancer_histology = Abstractor::AbstractorAbstractionSchema.where(predicate: 'has_cancer_histology').first
    @abstractor_subject_abstraction_schema_has_cancer_histology = Abstractor::AbstractorSubject.where(subject_type: PathologyCase.to_s, abstractor_abstraction_schema_id:@abstractor_abstraction_schema_has_cancer_histology.id).first
  end

  describe "abstracting" do
    it 'determines a suggestion endpiont', focus: false do
      expect(Abstractor::CustomNlpProvider.determine_suggestion_endpoint('custom_nlp_provider_name')).to eq('http://custom-nlp-provider.test/suggest')
    end

    it 'formats object values for submission to a custom nlp provider', focus: false do
      expect(Abstractor::CustomNlpProvider.abstractor_object_values(@abstractor_subject_abstraction_schema_has_cancer_histology)).to eq([{:value=>"carcinoma in situ, nos (8010/2)", :object_value_variants=>[{:value=>"carcinoma in situ, nos"}, {:value=>"intraepithelial carcinoma, nos"}, {:value=>"carcinoma in situ"}, {:value=>"intraepithelial carcinoma"}]}, {:value=>"carcinoma, nos (8010/3)", :object_value_variants=>[{:value=>"carcinoma, nos"}, {:value=>"carcinoma"}, {:value=>"malignant epithelial tumor"}, {:value=>"epithelial tumor malignant"}]}, {:value=>"carcinoma, metastatic, nos (8010/6)", :object_value_variants=>[{:value=>"carcinoma, metastatic, nos"}, {:value=>"secondary carcinoma"}, {:value=>"metastatic carcinoma"}, {:value=>"carcinoma metastatic"}]}])
    end

    it 'posts a message to a custom nlp provider to generate suggestions', focus: false do
      stub_request(:post, "http://custom-nlp-provider.test/suggest").to_return(:status => 200, :body => "", :headers => {})
      text = 'Looks like metastatic carcinoma to me.'
      @pathology_case = FactoryGirl.create(:pathology_case, note_text: text, patient_id: 1)
      @pathology_case.abstract

      abstractor_abstraction = @pathology_case.abstractor_abstractions_by_abstraction_schemas({abstractor_abstraction_schema_ids: [@abstractor_abstraction_schema_has_cancer_histology.id] }).first
      abstractor_abstraction_soruce = @abstractor_subject_abstraction_schema_has_cancer_histology.abstractor_abstraction_sources.first
      object_values = Abstractor::CustomNlpProvider.abstractor_object_values(@abstractor_subject_abstraction_schema_has_cancer_histology).to_json
      body = %{{"abstractor_abstraction_schema_id":#{@abstractor_abstraction_schema_has_cancer_histology.id},"abstractor_abstraction_id":#{abstractor_abstraction.id},"abstractor_abstraction_source_id":#{abstractor_abstraction_soruce.id},"source_id":#{@pathology_case.id},"source_type":"#{@pathology_case.class.to_s}","source_method":"note_text","text":"#{text}","object_values":#{object_values}}}
      expect(a_request(:post, "custom-nlp-provider.test/suggest").with(body: body, headers: { 'Content-Type' => 'application/json' })).to have_been_made
    end
  end
end