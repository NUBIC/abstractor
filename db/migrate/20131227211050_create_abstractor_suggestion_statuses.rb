class CreateAbstractorSuggestionStatuses < ActiveRecord::Migration
  def change
    create_table :abstractor_suggestion_statuses do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
