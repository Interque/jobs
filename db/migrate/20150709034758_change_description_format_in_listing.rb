class ChangeDescriptionFormatInListing < ActiveRecord::Migration
  def change
    change_column :listings, :description, :text, :limit => nil
  end
end
