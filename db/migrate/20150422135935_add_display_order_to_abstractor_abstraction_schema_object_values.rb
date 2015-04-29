class AddDisplayOrderToAbstractorAbstractionSchemaObjectValues < ActiveRecord::Migration
  def change
    add_column :abstractor_abstraction_schema_object_values, :display_order, :integer
  end
end
