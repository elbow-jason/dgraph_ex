defmodule DgraphEx do
  alias DgraphEx.{
    Query,
  }

  require DgraphEx.Vertex
  DgraphEx.Vertex.query_model()
  use DgraphEx.Field
  use DgraphEx.Expr

  require DgraphEx.Expr.Math
  defmacro math(block) do
    quote do
      DgraphEx.Expr.Math.math(unquote(block))
    end
  end
 

  use Query
  use Query.Mutation
  use Query.Schema
  use Query.Var
  use Query.As
  use Query.Select
  use Query.MutationSet
  use Query.Filter
  use Query.Block
  use Query.Directive
  use Query.Groupby
  
end
