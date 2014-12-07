class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.string :organization
      t.string :email
      t.integer :salary

      t.timestamps
    end
  end
end
