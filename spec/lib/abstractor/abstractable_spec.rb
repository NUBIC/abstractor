require 'spec_helper'

module Abstractor::Abstractable
  describe "including the module" do
    it "should detect if included into an ActiveRecord::Base model" do
      lambda {
        module Hello
          include Abstractor::Abstractable
        end
      }.should raise_error(RuntimeError, /Abstractor::Abstractable expects to be included into an ActiveRecord::Base model/)

      lambda {
        class RadiationTherapyPrescription < ActiveRecord::Base
          include Abstractor::Abstractable
        end
      }.should_not raise_error

      lambda {
        class HelloAgain < Abstractor::AbstractorAbout
          include Abstractor::Abstractable
        end
      }.should_not raise_error
    end
  end
end
