class CreateAbstractorSubjectGroups < ActiveRecord::Migration
  def change
    create_table :abstractor_subject_groups do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
