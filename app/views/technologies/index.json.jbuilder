json.array!(@technologies) do |technology|
  json.extract! technology, :id, :tech, :posted, :city, :state
  json.url technology_url(technology, format: :json)
end
