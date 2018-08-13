class CreateBowlings < ActiveRecord::Migration[5.0]
  def change
    create_table :bowlings do |t|
      t.integer :score
      t.string :frames

      t.timestamps
    end
  end
end
