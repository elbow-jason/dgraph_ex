defmodule DgraphEx.Repo do
  alias DgraphEx.Query

  def set(%Query{} = q) do
    q
    |> DgraphEx.assemble
    |> DgraphEx.render
    |> DgraphEx.Client.send
  end
  def set(%{__struct__: module} = model) do
    set(model, module.__vertex__(:default_label))
  end
  def set(%{__struct__: module} = model, label) do
    if has_function(module, :__vertex__, 1) do
      DgraphEx.query
      |> DgraphEx.mutation
      |> DgraphEx.set
      |> DgraphEx.model(label, model)
      |> set
    else
      model
      |> Map.from_struct
      |> set
    end
  end
  # def set(models) when is_list(models) do
  #   DgraphEx.new
  #   |> DgraphEx.mutation

  # end


  defp has_function(m, f, arity) do
    :erlang.function_exported(m, f, arity) 
  end
  
end