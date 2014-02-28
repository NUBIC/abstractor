class CreateAbstractorSubjects < ActiveRecord::Migration
  def change
    create_table :abstractor_subjects do |t|
      t.integer :abstractor_abstraction_schema_id
      t.integer :abstractor_rule_type_id
      t.string :subject_type
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
