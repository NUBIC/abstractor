class EncounterNote < ActiveRecord::Base
  include Abstractor::Abstractable
  attr_accessible :note_text
end
