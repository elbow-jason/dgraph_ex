defmodule DgraphEx.Expr do

  defmacro __using__(_) do
    alias DgraphEx.Expr
    quote do
      use Expr.Count
      use Expr.Eq
      use Expr.Uid
    end
  end
  
end