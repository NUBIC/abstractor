class CreateAbstractorAbstractionSchemaSources < ActiveRecord::Migration
  def change
    create_table :abstractor_abstraction_schema_sources do |t|
      t.string :name
      t.string :about_type
      t.string :namespace_type
      t.integer :namespace_id
      t.string :custom_nlp_provider
      t.string :from_method
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
