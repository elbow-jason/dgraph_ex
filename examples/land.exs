defmodule DgraphEx.Examples.Land do
  use DgraphEx.Vertex
  alias DgraphEx.Examples.{Land, Person}

  vertex :land do
    field :address,             :string,  index: [:exact, :term],  count: true
    field :zipcode,             :string,  index: [:exact],         count: true
    field :city,                :string,  index: [:exact],         count: true
    field :land_size,           :int,     index: true
    field :living_space,        :int,     index: true
    field :zoning,              :string,  index: [:exact],         count: true
    field :floors,              :int
    field :construction_year,   :string
    field :geo_center,          :geo,     index: [:geo]
    field :geo_border,          :geo,     index: [:geo]
    field :owner,               :uid,     model: Person, reverse: true
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
    construction_year
    assessor_sale_price
    owner
    seller
    geo_center
    geo_border
  )a
  

  def land_example() do
    %Land{
      address: "123 Maple Rd Phoenix, AZ 88888",
      zipcode: "88888",
      city: "Phoenix",
      land_size: 12,
      living_space: 8,
      zoning: "FAKE",
      floors: 1,
      construction_year: "1982",
      owner: %Person{
        name: "Jason Beefcake",
        address: "456 Maple Rd Phoenix, AZ 55555",
      }
    }
  end


end