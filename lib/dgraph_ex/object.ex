defmodule DgraphEx.Object do

  defmacro object(name, do: block) when is_atom(name) do
    quote do
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      def name() do
        unquote(name)
      end
      unquote(block)
      @before_compile DgraphEx.Object
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def fields() do
        @fields 
      end
      defstruct @fields |> Enum.map(fn {name, type, opts} -> {name, opts[:default]} end)
    end
  end
end