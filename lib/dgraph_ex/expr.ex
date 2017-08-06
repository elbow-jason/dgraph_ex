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
      require Expr.Neq
      Expr.Neq.define_funcs(Expr.Lt, :lt)
      Expr.Neq.define_funcs(Expr.Le, :le)
      Expr.Neq.define_funcs(Expr.Gt, :gt)
      Expr.Neq.define_funcs(Expr.Ge, :ge)
      use Expr.Allofterms
      use Expr.Anyofterms
      use Expr.Alloftext
      use Expr.Anyoftext
      use Expr.Regexp
    end
  end
  
end