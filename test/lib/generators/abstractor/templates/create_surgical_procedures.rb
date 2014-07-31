class CreateSurgicalProcedures < ActiveRecord::Migration
  def change
    create_table :surgical_procedures do |t|
      t.integer     :surg_case_id, :null => false
      t.string      :description, :null => false
      t.string      :modifier, :null => false
      t.timestamps
    end
  end
end