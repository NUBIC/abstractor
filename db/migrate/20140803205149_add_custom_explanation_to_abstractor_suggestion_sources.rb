class AddCustomExplanationToAbstractorSuggestionSources < ActiveRecord::Migration
  def change
    add_column :abstractor_suggestion_sources, :custom_explanation, :string
  end
end
