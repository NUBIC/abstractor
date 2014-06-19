class AddCustomMethodToAbstractorSuggestionSources < ActiveRecord::Migration
  def change
    add_column :abstractor_suggestion_sources, :custom_method, :string
  end
end
