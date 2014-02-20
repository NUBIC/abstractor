class RadiationTherapyPrescription < ActiveRecord::Base
  attr_accessible :site_name
  include Abstractor::Abstractable
end
