class AddLocationToListing < ActiveRecord::Migration
  def change
    add_column :listings, :location, :string
  end
end
