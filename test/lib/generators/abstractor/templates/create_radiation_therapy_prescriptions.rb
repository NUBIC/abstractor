class CreateRadiationTherapyPrescriptions < ActiveRecord::Migration
  def change
    create_table :radiation_therapy_prescriptions do |t|
      t.string     :site_name,                            :null => true
      t.timestamps
    end
  end
end