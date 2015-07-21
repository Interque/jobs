class AddCategoryToListing < ActiveRecord::Migration
  def change
    add_column :listings, :category, :array
  end
end
