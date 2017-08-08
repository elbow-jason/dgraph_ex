defmodule DgraphEx.Query.Directive do
  alias DgraphEx.Query.Directive

  defstruct [
    label: nil
  ]

  defmacro __using__(_) do
    quote do
      alias DgraphEx.Query.Directive

      def directive(label), do: Directive.new(label)
      def ignorereflex,     do: Directive.new(:ignorereflex)
      def cascade,          do: Directive.new(:cascade)
      def normalize,        do: Directive.new(:normalize)
    end
  end

  @labels [
    :ignorereflex,
    :cascade,
    :normalize,
  ]

  def new(label) when label in @labels do
    %Directive{
      label: label,
    }
  end

  def render(%Directive{label: label}) when label in @labels do
    "@#{label}"
  end

end