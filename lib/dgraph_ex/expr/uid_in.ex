defmodule DgraphEx.Expr.UidIn do
  @moduledoc """
  An example from https://docs.dgraph.io/query-language/#uid-in :
  
  ```
    {
      caro(func: eq(name, "Marc Caro")) {
        name@en
        director.film @filter(uid_in(~director.film, 597046)){
          name@en
        }
      }
    }
  ```
  """

  alias DgraphEx.Expr.UidIn

  defstruct [
    predicate: nil,
    uid:       nil,
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Expr.UidIn
      def uid_in(predicate, uid) when is_atom(predicate) and is_binary(uid) do
        UidIn.new(predicate, uid)
      end
    end
  end

  def new(predicate, uid) when is_atom(predicate) and is_binary(uid) do
    %UidIn{
      predicate: predicate,
      uid: uid,
    }
  end

  def render(%UidIn{predicate: predicate, uid: uid}) when is_atom(predicate) and is_binary(uid) do
    "uid_in(#{predicate}, #{uid})"
  end
  
end