class AddSubtypeToAbstractorSubjectGroups < ActiveRecord::Migration
  def change
    add_column :abstractor_subject_groups, :subtype, :string
  end
end
