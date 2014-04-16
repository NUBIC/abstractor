class CreateAbstractorAbouts < ActiveRecord::Migration
  def change
    create_table :abstractor_abouts do |t|
      t.string :type
      t.string :external_id

      t.timestamps
    end
  end
end
