class CreateIndexesForPerformance < ActiveRecord::Migration
  def change
    #abstractor_abstraction_group_members
    add_index :abstractor_abstraction_group_members, [:abstractor_abstraction_id], unique: false , name: 'index_abstractor_abstraction_id'
    add_index :abstractor_abstraction_group_members, [:abstractor_abstraction_group_id], unique: false , name: 'index_abstractor_abstraction_group_id'

    #abstractor_abstraction_groups
    add_index :abstractor_abstraction_groups, [:about_id, :about_type, :deleted_at], unique: false , name: 'index_about_id_about_type_deleted_at'

    #abstractor_abstractions
    add_index :abstractor_abstractions, [:about_id, :about_type, :deleted_at], unique: false , name: 'index_about_id_about_type_deleted_at_2'
    add_index :abstractor_abstractions, [:abstractor_subject_id], unique: false , name: 'index_abstractor_subject_id'

    #abstractor_subject_group_members
    add_index :abstractor_subject_group_members, [:abstractor_subject_id], unique: false , name: 'index_abstractor_subject_id_2'

    #abstractor_subjects
    add_index :abstractor_subjects, [:subject_type], unique: false , name: 'index_subject_type'
    add_index :abstractor_subjects, [:namespace_type, :namespace_id], unique: false , name: 'index_namespace_type_namespace_id'

    #abstractor_suggestion_sources
    add_index :abstractor_suggestion_sources, [:abstractor_suggestion_id], unique: false , name: 'index_abstractor_suggestion_id'

    #abstractor_suggestions
    add_index :abstractor_suggestions, [:abstractor_abstraction_id], unique: false , name: 'index_abstractor_abstraction_id_2'
  end
end