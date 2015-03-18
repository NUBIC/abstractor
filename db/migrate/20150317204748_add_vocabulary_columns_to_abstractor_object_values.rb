class AddVocabularyColumnsToAbstractorObjectValues < ActiveRecord::Migration
  def change
    add_column :abstractor_object_values, :vocabulary_code, :string
    add_column :abstractor_object_values, :vocabulary, :string
    add_column :abstractor_object_values, :vocabulary_version, :string
  end
end
