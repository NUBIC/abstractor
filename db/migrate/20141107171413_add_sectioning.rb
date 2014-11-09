class AddSectioning < ActiveRecord::Migration
  def up
    create_table :abstractor_abstraction_source_section_types do |t|
      t.string :name
      t.string :regular_expression
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :abstractor_abstraction_source_section_name_variants do |t|
      t.integer :abstractor_abstraction_source_id
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :abstractor_abstraction_sources, :abstractor_abstraction_source_section_type_id, :integer
    add_column :abstractor_abstraction_sources, :custom_section_regular_expression, :string
    add_column :abstractor_abstraction_sources, :return_note_on_empty_section, :boolean
  end

  def down
    drop_table :abstractor_abstraction_source_section_types
    drop_table :abstractor_abstraction_source_section_name_variants
    remove_column :abstractor_abstraction_sources, :abstractor_abstraction_source_section_type_id
    remove_column :abstractor_abstraction_sources, :custom_section_regular_expression
    remove_column :abstractor_abstraction_sources, :return_note_on_empty_section
  end
end