defmodule DgraphEx.Mutation do
  alias DgraphEx.{
    Field,
    Mutation,
    Schema,
  }

  alias Mutation.{
    MutationSet,
    MutationDelete,
  }

  @submodules [
    Schema,
    MutationSet,
    MutationDelete,
    Field,
  ]

  defstruct [
    sequence: []
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Mutation, Kwargs}

      def mutation() do
        %Mutation{}
      end

      def mutation(kwargs) when is_list(kwargs) do
        Kwargs.mutation(kwargs)
      end

    end
  end

  def new() do
    %Mutation{}
  end

  def put_sequence(%Mutation{sequence: rest} = mut, %{__struct__: module} = model) when module in @submodules do
    %{ mut | sequence: [ model | rest ]}
  end

  def render(%Mutation{sequence: seq}) do
    body =
      seq
      |> Enum.map(fn
        %{__struct__: module} = model -> module.render(model)
      end)
      |> Enum.filter(fn
        "" -> false
        item -> item
      end)
      |> Enum.join(" ")
    "mutation { " <> body <> " }"
  end

end