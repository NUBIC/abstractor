class AddCustomNlpProviderToAbstractorAbstractionSources < ActiveRecord::Migration
  def change
    add_column :abstractor_abstraction_sources, :custom_nlp_provider, :string
  end
end
