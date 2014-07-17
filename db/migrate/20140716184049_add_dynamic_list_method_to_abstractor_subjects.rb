class AddDynamicListMethodToAbstractorSubjects < ActiveRecord::Migration
  def change
    add_column :abstractor_subjects, :dynamic_list_method, :string
  end
end