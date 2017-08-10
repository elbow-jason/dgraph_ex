defmodule DgraphEx.SchemaTest do
  use ExUnit.Case
  doctest DgraphEx.Schema

  import DgraphEx
  import TestHelpers

  test "schema/1 can render a tuple of atoms" do
    assert clean_format("""
      schema {
        name
        age
      }
    """) == schema({
      :name,
      :age,
    })
    |> render
    |> clean_format
  end
end