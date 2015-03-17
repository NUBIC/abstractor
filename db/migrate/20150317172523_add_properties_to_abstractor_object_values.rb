class AddPropertiesToAbstractorObjectValues < ActiveRecord::Migration
  def change
    add_column :abstractor_object_values, :properties, :text
  end
end
