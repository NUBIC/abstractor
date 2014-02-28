with diagnosis_data as (
select  pc.id as pathology_case_id
      , max(case when abstractor_abstraction_schemas.id in (
      select subjects.id from abstractor_abstraction_schemas subjects
      join abstractor_abstraction_schema_relations on subjects.id = abstractor_abstraction_schema_relations.subject_id
      join abstractor_abstraction_schemas objects on abstractor_abstraction_schema_relations.object_id = objects.id
      join abstractor_relation_types on abstractor_abstraction_schema_relations.abstractor_relation_type_id = abstractor_relation_types.id
      where objects.predicate = 'has_diagnosis'
      and abstractor_relation_types.name = 'member_of')
      then abstractor_abstractions.value end) as diagnosis
      , max(case when abstractor_abstraction_schemas.predicate = 'has_anatomical_location' then abstractor_abstractions.value end) as anatomical_location
      , max(case when abstractor_abstraction_schemas.predicate = 'has_anatomical_location_of_primary' then abstractor_abstractions.value end) as anatomical_location_of_primary
      , max(case when abstractor_abstraction_schemas.predicate = 'has_laterality' then abstractor_abstractions.value end) as laterality
      , max(case when abstractor_abstraction_schemas.predicate = 'has_who_grade' then abstractor_abstractions.value end) as who_grade
      , max(case when abstractor_abstraction_schemas.predicate = 'is_recurrent' then abstractor_abstractions.value end) as recurrent
      from pathology_cases pc
      join abstractor_abstractions on abstractor_abstractions.subject_id = pc.id
      join abstractor_subjects on abstractor_abstractions.abstractor_subject_id = abstractor_subjects.id
      join abstractor_abstraction_schemas on abstractor_subjects.abstractor_abstraction_schema_id = abstractor_abstraction_schemas.id
      join abstractor_abstraction_group_members on abstractor_abstraction_group_members.abstractor_abstraction_id = abstractor_abstractions.id
      where (abstractor_abstraction_schemas.predicate in('has_anatomical_location_of_primary','has_anatomical_location', 'has_laterality', 'has_who_grade', 'is_recurrent')
      or abstractor_abstraction_schemas.id in (
      select subjects.id from abstractor_abstraction_schemas subjects
      join abstractor_abstraction_schema_relations on subjects.id = abstractor_abstraction_schema_relations.subject_id
      join abstractor_abstraction_schemas objects on abstractor_abstraction_schema_relations.object_id = objects.id
      join abstractor_relation_types on abstractor_abstraction_schema_relations.abstractor_relation_type_id = abstractor_relation_types.id
      where objects.predicate = 'has_diagnosis'
      and abstractor_relation_types.name = 'member_of'))
      and abstractor_abstractions.value is not null
      group by pc.id, abstractor_abstraction_group_members.abstractor_abstraction_group_id
)
select dd.*
      , max(case when abstractor_abstraction_schemas.predicate = 'has_IDH1_status' then abstractor_abstractions.value end) as idh1_status
      , max(case when abstractor_abstraction_schemas.predicate = 'has_1p_status' then abstractor_abstractions.value end) as one_p_status
      , max(case when abstractor_abstraction_schemas.predicate = 'has_19q_status' then abstractor_abstractions.value end) as nineteen_q_status
      , max(case when abstractor_abstraction_schemas.predicate = 'has_10q_pten_status' then abstractor_abstractions.value end) as ten_q_pten_status
      , max(case when abstractor_abstraction_schemas.predicate = 'has_ki67' then abstractor_abstractions.value end) as ki67
      , max(case when abstractor_abstraction_schemas.predicate = 'has_p53' then abstractor_abstractions.value end) as p53

from diagnosis_data dd
join abstractor_abstractions on abstractor_abstractions.subject_id = dd.pathology_case_id
join abstractor_subjects on abstractor_abstractions.abstractor_subject_id = abstractor_subjects.id
join abstractor_abstraction_schemas on abstractor_subjects.abstractor_abstraction_schema_id = abstractor_abstraction_schemas.id
group by dd.pathology_case_id, dd.diagnosis, dd.anatomical_location, dd.laterality, dd.who_grade, dd.recurrent, dd.anatomical_location_of_primary
order by dd.pathology_case_id

