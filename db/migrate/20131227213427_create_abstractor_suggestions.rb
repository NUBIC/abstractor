class CreateAbstractorSuggestions < ActiveRecord::Migration
  def change
    create_table :abstractor_suggestions do |t|
      t.integer :abstraction_id
      t.integer :suggestion_status_id
      t.string :suggested_value
      t.boolean :unknown
      t.boolean :not_applicable
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
