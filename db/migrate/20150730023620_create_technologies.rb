class CreateTechnologies < ActiveRecord::Migration
  def change
    create_table :technologies do |t|
      t.string :name
      t.string :city
      t.string :state
      t.datetime :posted

      t.timestamps
    end
  end
end
