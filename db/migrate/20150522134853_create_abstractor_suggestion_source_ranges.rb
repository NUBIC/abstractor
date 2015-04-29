class CreateAbstractorSuggestionSourceRanges < ActiveRecord::Migration
  def change
    create_table :abstractor_suggestion_source_ranges do |t|
      t.integer :abstractor_suggestion_source_id, null: false
      t.integer :begin_position
      t.integer :end_position

      t.timestamps null: false
    end
  end
end
