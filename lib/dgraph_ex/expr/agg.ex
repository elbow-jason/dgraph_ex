defmodule DgraphEx.Expr.Agg do

  defmacro define_funcs(module, name) do
    quote do
      def unquote(name)(%DgraphEx.Expr.Val{} = val) do
        %unquote(module){
          val: val,
        }
      end
    end
  end

  defmacro __using__(name) do
    quote do
      alias DgraphEx.Expr.{Val}
      alias DgraphEx.Util

      defstruct [
        val: nil
      ]

      @doc """

      Aggregation

      Syntax Example: AG(val(varName))

      For AG replaced with

      min : select the minimum value in the value variable varName
      max : select the maximum value
      sum : sum all values in value variable varName
      avg : calculate the average of values in varName

      """
      def render(%__MODULE__{val: %Val{} = val}) do
        val
        |> Val.render
        |> do_render()
      end

      defp do_render(rendered_val) do
        "#{unquote(name)}(#{rendered_val})"
      end

    end
  end
end 
