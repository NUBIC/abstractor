class CreateAbstractorSubjectGroupMembers < ActiveRecord::Migration
  def change
    create_table :abstractor_subject_group_members do |t|
      t.integer :abstractor_subject_id
      t.integer :subject_group_id
      t.integer :display_order
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
