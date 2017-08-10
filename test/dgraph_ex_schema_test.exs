defmodule DgraphEx.SchemaTest do
  use ExUnit.Case
  doctest DgraphEx.Schema

  import DgraphEx
  import TestHelpers

  alias DgraphEx.ModelPerson, as: Person

  test "schema/1 can render a tuple of atoms" do
    assert clean_format("""
      schema(pred: [name, age]) {
        type
        index
        reverse
        tokenizer
      }
    """) == schema({
      :name,
      :age,
    })
    |> render
    |> clean_format
  end

  test "schema/1 can render a tuple of fields" do
    assert clean_format("""
      schema(pred: [name, age]) {
        type
        index
        reverse
        tokenizer
      }
    """) == schema({
      field(:name, :string),
      :age,
    })
    |> render
    |> clean_format
  end

  test "schema/1 can render a model's schema" do
    assert clean_format("""
      schema(pred: [name, age, works_at, _uid_]) {
        type
        index
        reverse
        tokenizer
      }
    """) == schema(%Person{})
    |> render
    |> clean_format
  end

end