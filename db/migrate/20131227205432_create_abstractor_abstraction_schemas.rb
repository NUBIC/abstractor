class CreateAbstractorAbstractionSchemas < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_schemas do |t|
      t.string :predicate
      t.string :display_name
      t.integer :abstractor_object_type_id
      t.string :preferred_name
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
