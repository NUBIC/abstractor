class AddSectioning < ActiveRecord::Migration
  def up
    create_table :abstractor_sections do |t|
      t.integer :abstractor_section_type_id
      t.string :source_type
      t.string :source_method
      t.string :name
      t.string :description
      t.string :delimiter
      t.string :custom_regular_expression
      t.boolean :return_note_on_empty_section
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :abstractor_section_types do |t|
      t.string :name
      t.string :regular_expression
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :abstractor_section_name_variants do |t|
      t.integer :abstractor_section_id
      t.string :name
      t.datetime :deleted_at
      t.timestamps
    end

    add_column :abstractor_abstraction_sources, :section_name, :string
    add_column :abstractor_suggestion_sources, :section_name, :string
  end

  def down
    drop_table :abstractor_sections
    drop_table :abstractor_section_types
    drop_table :abstractor_section_name_variants
    remove_column :abstractor_abstraction_sources, :section_name
    remove_column :abstractor_suggestion_sources, :section_name
  end
end