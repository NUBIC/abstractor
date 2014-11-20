class AddSystemGeneratedToAbstractorAbstractionGroups < ActiveRecord::Migration
  def change
    add_column :abstractor_abstraction_groups, :system_generated, :boolean, default: false
  end
end
