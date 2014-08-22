class AddNamespaceToAbstractorSubjects < ActiveRecord::Migration
  def change
    add_column :abstractor_subjects, :namespace_type, :string
    add_column :abstractor_subjects, :namespace_id, :integer
  end
end
