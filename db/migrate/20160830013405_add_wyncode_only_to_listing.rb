class AddWyncodeOnlyToListing < ActiveRecord::Migration
  def change
    add_column :listings, :wyncode_only, :boolean, default: false
  end
end
