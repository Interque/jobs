class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :ip
      t.string :state
      t.string :city
      t.string :zip
      t.string :country
      t.references :user, index: true

      t.timestamps
    end
  end
end
