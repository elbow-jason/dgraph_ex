# DgraphEx 
[![Build Status](https://travis-ci.org/elbow-jason/dgraph_ex.svg?branch=master)](https://travis-ci.org/elbow-jason/dgraph_ex) [![Hex Version][hex-img]][hex] [![License][license-img]][license]

[hex-img]: https://img.shields.io/hexpm/v/dgraph_ex.svg
[hex]: https://hex.pm/packages/dgraph_ex
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg
[license]: http://opensource.org/licenses/MIT

An elixir database wrapper for dgraph database.

Works with dgraph v0.8.1 (most current release as of 16 AUG 2017)

[Docs](https://hexdocs.pm/dgraph_ex)

##### Installation: 

```elixir
def deps do
  [{:dgraph_ex, "~> 0.1.0"}]
end
```


## Usage 

#### define a model

```elixir

defmodule Person do
  use DgraphEx.Vertex

  vertex :person do
    field :name,    :string, index: [:exact, :term]
    field :address, :string, index: [:exact, :term]
  end
end

```

```elixir

defmodule Land do
  use Vertex

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
end

```

#### mutate the schema

```elixir
import DgraphEx
alias DgraphEx.Repo

{:ok, _} = Repo.request mutation(schema: Land)
{:ok, _} = Repo.request mutation(schema: Person)

```

#### define a changeset

```elixir

  alias DgraphEx.Changeset

  def changeset(%Person{} = model, changes) when is_map(changes) do
    model
    |> Changeset.cast(changes, _allowed_fields = [:name, :address])
    |> Changeset.validate_required(_required_fields = [:name, :address])
    |> Changeset.validate_type(_typed_fields = [:name, :address])
    |> Changeset.uncast
  end

```

#### insert a model

We apply the `changeset` function to ensure data consistency:

```elixir
{:ok, person} =
  %Person{} 
  |> Person.changeset(%{name: "jason", address: "221B Baker St. London, England 55555"})
```

And `person` is:

```elixir
  %Person{
    _uid_: nil,
    address: "221B Baker St. London, England 55555",
    name: "jason",
  }
```

Then we insert into the `Repo`:

```elixir
{:ok, person} = Repo.insert(person)
```

The resulting `person` is:

(notice the `_uid_` is populated)

```elixir
%Person{
  _uid_: "0x11c",
  address: "221B Baker St. London, England 55555",
  name: "jason",
}
```

#### update a model

Using the `person` from above:

```elixir
{:ok, person} = Person.changeset(person, %{name: "John Lakeman"})
person = Repo.update(person)
```

#### get a model by `_uid_`.

Coming soon.

#### find anything

With function syntax:

```elixir

import DgraphEx

query()
|> func(:spy, eq(:name, "John Lakeman"))
|> select({
  :_uid_,
  :address,
  :name,
})
|> Repo.request

```

Again with keyword (kwargs) syntax:

```elixir
import DgraphEx
alias DgraphEx.Repo

query([
  get: :spy,
  func: eq(:name, "John Lakeman"),
  select: {
    :_uid_,
    :address,
    :name,
  },
]) |> Repo.request

```

Both of the above requests for "spy" result in the same response:

```elixir
{:ok, %{
  "spy" => [
    %{
      "_uid_" => "0x11c",
      "address" => "221B Baker St. London, England 55555",
      "name" => "John Lakeman",
    }
  ]
}}

```
