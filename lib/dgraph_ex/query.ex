defmodule DgraphEx.Query do
   alias DgraphEx.{
    # Field,
    Query,
  }
  alias Query.{
    As,
    Var,
    Block,
    Groupby,
  }

  @bracketed [
    As,
    Var,
    Groupby,
  ]

  defstruct [
    sequence: [],
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.{Query, Kwargs}

      def query do
        %Query{}
      end

      def query(kwargs) when is_list(kwargs) do
        Kwargs.query(kwargs)
      end

      def render(x) do
        Query.render(x)
      end

    end
  end

  def merge(%Query{sequence: seq1}, %Query{sequence: seq2}) do
    %Query{sequence: seq2 ++ seq1 }
  end

  def put_sequence(%__MODULE__{sequence: prev_sequence} = d, prefix) when is_list(prefix) do
    %{ d | sequence: prefix ++ prev_sequence }
  end
  def put_sequence(%__MODULE__{sequence: sequence} = d, item) do
    %{ d | sequence: [ item | sequence ]  }
  end

  def render(%Query{sequence: backwards_sequence}) do
    case backwards_sequence |> Enum.reverse do
      [ %Block{keywords: [{:func, _ } | _ ]} | _ ] = sequence ->
        sequence
        |> render_sequence
        |> with_brackets
      [ %module{} | _ ] = sequence when module in @bracketed ->
        sequence
        |> render_sequence
        |> with_brackets
      sequence when is_list(sequence) ->
        sequence
        |> render_sequence
      %module{} = model ->
        module.render(model)
    end
  end

  def render(block) when is_tuple(block) do
    Block.render(block)
  end

  def render(%module{} = model) do
    module.render(model)
  end

  defp render_sequence(sequence) do
    sequence
    |> Enum.map(fn
      %module{} = model -> module.render(model)
    end)
    |> Enum.join(" ")
  end

  defp with_brackets(rendered) do
    "{ " <> rendered <> " }"
  end

end