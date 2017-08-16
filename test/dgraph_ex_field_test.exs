defmodule DgraphEx.FieldTest do
  use ExUnit.Case

  doctest DgraphEx.Field

  alias DgraphEx.Field
  alias DgraphEx.Expr.Uid


  # import DgraphEx
  # import TestHelpers

  test "a field as_setter can render `uid pred uid .` correctly " do
    my_field = %Field{
      subject:    %Uid{value: "1234", type: :literal},
      type:       :uid_literal,
      predicate:  :owner,
      object:     %Uid{value: "5678", type: :literal},
    }
    assert Field.as_setter(my_field) == "<1234> <owner> <5678> ."
  end

end