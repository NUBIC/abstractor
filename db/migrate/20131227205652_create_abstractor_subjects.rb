class CreateAbstractorSubjects < ActiveRecord::Migration
  def change
    create_table :abstractor_subjects do |t|
      t.integer :abstraction_schema_id
      t.integer :rule_type_id
      t.string :subject_type
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
