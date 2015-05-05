class AddSubtypeToAbstractorAbstractionGroups < ActiveRecord::Migration
  def change
    add_column :abstractor_abstraction_groups, :subtype, :string
  end
end
