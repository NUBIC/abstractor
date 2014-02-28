class CreateAbstractorAbstractions < ActiveRecord::Migration
  def change
    create_table :abstractor_abstractions do |t|
      t.integer :abstractor_subject_id
      t.string :value
      t.string :about_type
      t.integer :about_id
      t.string :value
      t.boolean :unknown
      t.boolean :not_applicable
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
