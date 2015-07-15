class AddSourceToListing < ActiveRecord::Migration
  def change
    add_column :listings, :source, :string, :default => "interque"
    add_column :listings, :posted, :datetime
  end
end
