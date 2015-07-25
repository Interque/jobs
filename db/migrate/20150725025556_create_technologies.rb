class CreateTechnologies < ActiveRecord::Migration
  def change
    create_table :technologies do |t|
      t.string :tech
      t.datetime :posted
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
