class CreateAbstractorSubjectRelations < ActiveRecord::Migration
  def change
    create_table :abstractor_subject_relations do |t|
      t.integer :subject_id
      t.integer :object_id
      t.integer :relation_type_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
