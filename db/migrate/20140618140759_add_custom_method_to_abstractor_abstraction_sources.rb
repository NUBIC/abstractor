class AddCustomMethodToAbstractorAbstractionSources < ActiveRecord::Migration
  def change
    add_column :abstractor_abstraction_sources, :custom_method, :string
  end
end
