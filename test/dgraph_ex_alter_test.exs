defmodule DgraphEx.AlterTest do
  use ExUnit.Case
  doctest DgraphEx.Alter

  test "render/1 renders an alter struct correctly" do
    one = %DgraphEx.Field{index: true, subject: "123", predicate: "loves", object: "cooking", type: :string}
    two = %DgraphEx.Field{index: true, subject: "123", predicate: "hates", object: "mean birds", type: :string}
    assert DgraphEx.Alter.new([one, two]) |> DgraphEx.Alter.render == "loves: string @index(string) .\nhates: string @index(string) ."
  end


end