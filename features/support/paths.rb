module NavigationHelpers
  def path_to(page_name)
    case page_name

    when /the home page/
      root_path
    when /the namespace_type "(.*?)" and namespace_id (\d+) sent to the last imaging exam edit page/
      edit_imaging_exam_path(ImagingExam.last, namespace_type: $1, namespace_id: $2)
    when /the last surgery edit page/
      edit_surgery_path(Surgery.last)
    when /the last pathology case edit page/
      edit_pathology_case_path(PathologyCase.last)
    when /the last encounter note edit page/
      edit_encounter_note_path(EncounterNote.last)
    when /the last radiation therapy prescription edit page/
      edit_radiation_therapy_prescription_path(RadiationTherapyPrescription.last)
    # Add more page name => path mappings here
    when /the radiation therapies index page/
      radiation_therapy_prescriptions_path()
    when /the encounter notes index page/
      encounter_notes_path()
    else
      if path = match_rails_path_for(page_name)
        path
      else
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
      end
    end
  end

  def match_rails_path_for(page_name)
    if page_name.match(/the (.*) page/)
      return send "#{$1.gsub(" ", "_")}_path" rescue nil
    end
  end
end

World(NavigationHelpers)