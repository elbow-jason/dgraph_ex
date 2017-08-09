defmodule DgraphEx.ModelCompany do
  use DgraphEx.Vertex

  vertex :company do
    field :name, :string
    field :owner, :uid, model: DgraphEx.ModelPerson, reverse: true
  end

end