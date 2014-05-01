class CreateAbstractorRelationTypes < ActiveRecord::Migration
  def change
    create_table :abstractor_relation_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
