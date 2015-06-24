class EncounterNote < ActiveRecord::Base
  include Abstractor::Abstractable
  # attr_accessible :note_text

  def custom_method
    [{ source_type: nil , source_id: nil , source_method: nil }]
  end

  def custom_method_nil
    nil
  end

  def broken_custom_method
    []
  end

  def encounter_date(abstractor_abstraction)
    [{ suggestion: '2014-06-26', explanation: 'A bit of custom logic.' }]
  end

  def encounter_date_without_text(abstractor_abstraction)
    [{ suggestion: '2014-07-26', explanation: 'A bit more of custom logic.' }]
  end

  def empty_encounter_date(abstractor_abstraction)
    []
  end
end
