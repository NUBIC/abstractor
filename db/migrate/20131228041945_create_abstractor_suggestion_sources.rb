class CreateAbstractorSuggestionSources < ActiveRecord::Migration
  def change
    create_table :abstractor_suggestion_sources do |t|
      t.integer :abstraction_source_id
      t.integer :suggestion_id
      t.text :match_value
      t.integer :source_id
      t.string :source_method
      t.string :source_type
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
