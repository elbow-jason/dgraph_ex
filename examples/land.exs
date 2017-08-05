defmodule DgraphEx.Example.Land do
  use Vertex

  vertex do
    field :parcel_number,       :string, index: [:exact],         count: true
    field :address,             :string, index: [:exact, :term],  count: true
    field :zipcode,             :string, index: [:exact],         count: true
    field :city,                :string, index: [:exact],         count: true
    field :land_size,           :int,    index: true
    field :living_space,        :int,    index: true
    field :zoning,              :string, index: [:exact],         count: true
    field :floors,              :int
    field :geo_center,          :geo, index: [:geo]
    field :geo_border,          :geo, index: [:geo]
    field :construction_year,   :string
    field :assessor_sale_price, :int
    field :owner,               :uid, model: Person, reverse: true
    field :seller,              :uid, model: Person, reverse: true
  end

  @allowed ~w(
    parcel_number
    address
    zipcode
    city
    land_size
    living_space
    zoning
    floors
    geo_center
    geo_border
    construction_year
    assessor_sale_price
    owner
    seller
  )a

  def example

end