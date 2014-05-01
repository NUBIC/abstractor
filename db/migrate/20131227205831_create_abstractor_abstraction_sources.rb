class CreateAbstractorAbstractionSources < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_sources do |t|
      t.integer :abstractor_subject_id
      t.string :from_method
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
