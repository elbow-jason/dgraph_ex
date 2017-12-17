defmodule DgraphEx.Error do
  defstruct [
    code: nil,
    message: nil
  ]

  def new(code, message) do
    %__MODULE__{code: code, message: message}
  end
  def new(%{"code" => code, "message" => message}) do
    new(code, message)
  end

end