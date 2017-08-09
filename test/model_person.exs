defmodule DgraphEx.ModelPerson do
  use DgraphEx.Vertex

  vertex :person do
    field :name,      :string
    field :age,       :int
    field :works_at,  :uid, model: DgraphEx.ModelCompany
  end

end
