class CreateAbstractorObjectValues < ActiveRecord::Migration
  def change
    create_table :abstractor_object_values do |t|
      t.string :value
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
