defmodule DgraphEx.Expr.Regexp do
  alias DgraphEx.Expr.Regexp
  alias DgraphEx.Util

  defstruct [
    label: nil,
    regex: nil,
  ]

  defmacro __using__(_) do
    quote do
      def regexp(label, regex) do
        DgraphEx.Expr.Regexp.new(label, regex)
      end
    end
  end

  def new(label, regex) when is_atom(label) and is_binary(regex) do
    new(label, Regex.compile!(regex))
  end
  
  def new(label, regex) when is_atom(label) do
    if Regex.regex?(regex) do
      %Regexp{label: label, regex: regex}
    else
      raise %RuntimeError{message: "Invalid Regex. Got: #{inspect regex}"}
    end
  end

  def render(%Regexp{label: label, regex: regex}) do
    "regexp(" <> Util.as_rendered(label) <> ", " <> render_regex(regex) <> ")"
  end

  defp render_regex(regex) do
    regex
    |> Regex.source
    |> wrap_slashes
    |> append_options(regex)
  end

  defp wrap_slashes(str) do
    "/"<>str<>"/"
  end

  defp append_options(str, regex) do
    str<>Regex.opts(regex)
  end
end