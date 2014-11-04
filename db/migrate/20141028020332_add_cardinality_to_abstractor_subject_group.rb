class AddCardinalityToAbstractorSubjectGroup < ActiveRecord::Migration
  def change
    add_column :abstractor_subject_groups, :cardinality, :integer
  end
end
