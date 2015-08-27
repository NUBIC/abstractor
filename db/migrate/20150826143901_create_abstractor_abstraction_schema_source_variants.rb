class CreateAbstractorAbstractionSchemaSourceVariants < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_schema_source_variants do |t|
      t.integer :abstractor_abstraction_schema_source_id
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
