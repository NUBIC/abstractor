class RefactorAbstractorRuleTypes < ActiveRecord::Migration
  def up
    create_table :abstractor_abstraction_source_types do |t|
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :abstractor_abstraction_sources, :abstractor_abstraction_source_type_id, :integer
    add_column :abstractor_abstraction_sources, :abstractor_rule_type_id, :integer
    remove_column :abstractor_subjects, :abstractor_rule_type_id

    create_table  :abstractor_indirect_sources do |t|
      t.integer   :abstractor_abstraction_id
      t.integer   :abstractor_abstraction_source_id
      t.string    :source_type
      t.integer   :source_id
      t.string    :source_method
      t.datetime  :deleted_at
      t.timestamps
    end
  end

  def down
    drop_table :abstractor_abstraction_source_types
    remove_column :abstractor_abstraction_sources, :abstractor_abstraction_source_type_id
    add_column :abstractor_subjects, :abstractor_rule_type_id, :integer
  end
end