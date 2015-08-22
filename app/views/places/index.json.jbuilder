json.array!(@places) do |place|
  json.extract! place, :id, :name, :category, :address, :latitude, :longitude, :tel, :url
  json.url place_url(place, format: :json)
end
