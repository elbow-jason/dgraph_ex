defmodule DgraphEx.Expr do

  defmacro __using__(_) do
    alias DgraphEx.Expr
    quote do

      # indexes
      use Expr.Eq
      use Expr.Allofterms
      use Expr.Anyofterms
      use Expr.Alloftext
      use Expr.Anyoftext
      use Expr.Regexp

      #Neq indexes
      require Expr.Neq
      Expr.Neq.define_funcs(Expr.Lt, :lt)
      Expr.Neq.define_funcs(Expr.Le, :le)
      Expr.Neq.define_funcs(Expr.Gt, :gt)
      Expr.Neq.define_funcs(Expr.Ge, :ge)

      # aggs
      require Expr.Agg
      Expr.Agg.define_funcs(Expr.Sum, :sum)
      Expr.Agg.define_funcs(Expr.Avg, :avg)
      Expr.Agg.define_funcs(Expr.Min, :min)
      Expr.Agg.define_funcs(Expr.Max, :max)

      # geo
      use Expr.Near
      use Expr.Within
      use Expr.Contains
      use Expr.Intersects

      # simples
      use Expr.Val
      use Expr.Count
      use Expr.Uid
      use Expr.Has
      use Expr.Expand
      use Expr.UidIn

    end
  end
  
end