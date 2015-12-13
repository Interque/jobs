class AddCountryToListing < ActiveRecord::Migration
  def change
    add_column :listings, :country, :string
  end
end
