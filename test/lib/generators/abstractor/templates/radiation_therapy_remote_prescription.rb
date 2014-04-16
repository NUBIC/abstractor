class RadiationTherapyRemotePrescription < Abstractor::AbstractorAbout
  include Abstractor::Abstractable

  attr_accessor :site_name

  def after_initialize(params={})
    @site_name  = params[:site_name]
  end
end
