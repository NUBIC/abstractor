class CreateAbstractorAbstractionSchemaObjectValues < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_schema_object_values do |t|
      t.integer :abstraction_schema_id
      t.integer :object_value_id
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
