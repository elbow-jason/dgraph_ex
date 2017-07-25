defmodule DgraphEx do

  def query(template) do
    template
    |> DgraphEx.Client.send
  end
  def query(variables, template) do
    variables
    |> DgraphEx.Template.prepare(template)
    |> DgraphEx.Client.send
  end

end
