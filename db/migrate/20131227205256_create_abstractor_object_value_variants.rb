class CreateAbstractorObjectValueVariants < ActiveRecord::Migration
  def change
    create_table :abstractor_object_value_variants do |t|
      t.integer :abstractor_object_value_id
      t.string :value
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
