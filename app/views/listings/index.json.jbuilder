json.array!(@listings) do |listing|
  json.extract! listing, :id, :title, :description, :organization, :email, :salary
  json.url listing_url(listing, format: :json)
end
