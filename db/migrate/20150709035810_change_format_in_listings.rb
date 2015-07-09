class ChangeFormatInListings < ActiveRecord::Migration
  def change
    change_column :listings, :organization, :text, :limit => nil
    change_column :listings, :title, :text, :limit => nil
    change_column :listings, :email, :text, :limit => nil
  end
end
