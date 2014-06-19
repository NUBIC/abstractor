class EncounterNote < ActiveRecord::Base
  include Abstractor::Abstractable
  attr_accessible :note_text

  def custom_method
    [{ source_type: nil , source_id: nil , source_method: nil }]
  end

  def custom_method_nil
    nil
  end

  def broken_custom_method
    []
  end

  def encounter_date
    ['2014-06-26']
  end

  def empty_encounter_date
    []
  end
end
