class CreateAbstractorAbstractionGroups < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_groups do |t|
      t.integer :subject_group_id
      t.string :subject_type
      t.integer :subject_id

      t.datetime :deleted_at

      t.timestamps
    end
  end
end
