class RadiationTherapyPrescription < ActiveRecord::Base
  include Abstractor::Abstractable
  attr_accessible :site_name
end
