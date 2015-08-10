class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :name
      t.integer :number

      t.timestamps
    end
  end
end
