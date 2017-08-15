defmodule DgraphEx do
  alias DgraphEx.{
    Query,
    Mutation,
  }

  require DgraphEx.Vertex
  DgraphEx.Vertex.query_model()
  use DgraphEx.Field
  use DgraphEx.Expr
  use DgraphEx.Schema

  use Mutation
  use DgraphEx.Mutation.MutationSet
  use DgraphEx.Mutation.MutationDelete

  use Query
  use Query.Var
  use Query.As
  use Query.Select
  use Query.Filter
  use Query.Block
  use Query.Directive
  use Query.Groupby

  require DgraphEx.Expr.Math
  defmacro math(block) do
    quote do
      DgraphEx.Expr.Math.math(unquote(block))
    end
  end

end
