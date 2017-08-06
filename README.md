# DgraphEx

An elixir database wrapper for dgraph database.

This is a work in progress.

## Usage 

```elixir
  defmodule DgraphEx.Examples.Person do
    use DgraphEx.Vertex

    vertex do
      field :name,    :string, index: [:exact, :term]
      field :address, :string, index: [:exact, :term]
    end
  end
```
```elixir

  person = 
    %DgraphEx.Examples.Person{
      name: "Jason Goldberger",
      address: "123 Maple Rd Phoenix, AZ 85255"
    }
  rendered =
    DgraphEx.new
    |> DgraphEx.mutation
    |> DgraphEx.set
    |> DgraphEx.model(:person, person)
    |> DgraphEx.assemble
    |> DgraphEx.render

  IO.puts(rendered)


  result =
    rendered
    |> DgraphEx.Client.send
  
  IO.puts("#{inspect result}")
```

```elixir
  rendered =
    DgraphEx.new
    |> DgraphEx.mutation
    |> DgraphEx.set
    |> DgraphEx.field(:person, :name, "Bill Wiggins", :string)
    |> DgraphEx.field(:person, :address, "123 Oak St. Scottsdale, AZ 85251", :string)
    |> DgraphEx.assemble
    |> DgraphEx.render

  IO.puts("rendered: #{rendered}")
  # rendered:
  # mutation {
  #   set {
  #     _:person <address> "123 Oak St. Scottsdale, AZ 85251"^^<xs:string> .
  #     _:person <name> "Bill Wiggins"^^<xs:string> .
  #   }
  # }
  result =
    rendered
    |> DgraphEx.Client.send

  IO.puts("result: #{inspect result}")
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dgraph_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:dgraph_ex, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/dgraph_ex](https://hexdocs.pm/dgraph_ex).

