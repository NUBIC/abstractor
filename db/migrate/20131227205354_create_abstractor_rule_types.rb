class CreateAbstractorRuleTypes < ActiveRecord::Migration
  def change
    create_table :abstractor_rule_types do |t|
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
