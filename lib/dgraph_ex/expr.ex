defmodule DgraphEx.Expr do

  defmacro __using__(_) do
    alias DgraphEx.Expr
    quote do
      # anywheres
      use Expr.Val
      use Expr.Count
      use Expr.Uid
      
      # indexes
      use Expr.Eq
      use Expr.Allofterms
      use Expr.Regexp
    end
  end
  
end