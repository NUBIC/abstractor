class CreateSurgeries < ActiveRecord::Migration
  def change
    create_table :surgeries do |t|
      t.integer     :surg_case_id, :null => false
      t.string      :surg_case_nbr, :null => false
      t.integer     :patient_id, :null => false
      t.timestamps
    end
  end
end
