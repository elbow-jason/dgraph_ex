defmodule DgraphEx.Query.Var do
  alias DgraphEx.Query
  # alias Query.{Var, Func}

  defstruct [
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query
      def var(%Query{} = q) do
        Query.put_sequence(q, Query.Var)
      end
    end
  end

end