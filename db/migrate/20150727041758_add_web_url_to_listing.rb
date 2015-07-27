class AddWebUrlToListing < ActiveRecord::Migration
  def change
    add_column :listings, :web_url, :string
  end
end
