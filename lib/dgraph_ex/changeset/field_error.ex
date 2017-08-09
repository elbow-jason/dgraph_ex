defmodule DgraphEx.Changeset.FieldError do
  alias DgraphEx.Changeset.FieldError
  alias DgraphEx.Field
  defstruct [
    field: nil,
    reason: nil,
  ]

  def new(%Field{} = field, reason) when is_atom(reason) do
    %FieldError{
      field:  field,
      reason: reason,
    }
  end

end