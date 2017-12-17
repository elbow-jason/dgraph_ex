defmodule DgraphEx.Response do
  alias DgraphEx.{Response, Request}

  defstruct [
    status:     nil,
    data:       nil,
    errors:     [],
    code:       nil,
    message:    nil,
    uids:       %{},
    request:    nil,
    json:       nil,
    extensions: nil,
  ]

  def from_http_response({:ok, resp}, request) do
    from_http_response(resp, request)
  end
  def from_http_response({:error, %{reason: status}}, request) do
    new_error(:invalid_response, status, request)
  end
  def from_http_response(%HTTPoison.Response{} = http_resp, request) do
    case Poison.decode(http_resp.body) do
      {:ok, json} when is_map(json) ->
        new(http_resp.status_code, json, request)
        |> validate
      {:error, reason} ->
        new_error(:invalid_json, reason)
    end
  end
  def from_http_response(%HTTPoison.Error{reason: status}, request) do
    new_error(:http_error, status, request)
  end

  defp get_json(json, field, default \\ nil) do
    cond do
      Map.has_key?(json, field) ->
        json
        |> Map.get(field)
      Map.has_key?(json, "data") ->
        json
        |> Map.get("data")
        |> Kernel.||(%{})
        |> get_json(field, default)
      true ->
        default
    end
  end

  def new(status, json, %Request{} = request) when is_map(json) do
    IO.inspect(json, label: :response_json)
    %Response{
      status:       status,
      json:         json,
      code:         get_json(json, "code"),
      message:      get_json(json, "message"),
      uids:         get_json(json, "uids"),
      data:         json |> Map.get("data") |> Map.drop(["code", "message", "uids"]),
      extensions:   Map.get(json, "extensions", %{}),
      errors:       json |> Map.get("errors", []) |> Enum.map(&DgraphEx.Error.new/1),
      request:      request,
    }
  end

  def validate(%Response{errors: errors} = resp) when length(errors) > 0 do
    {:error, resp}
  end
  def validate(%Response{status: 200} = resp) do
    {:ok, resp}
  end
  def validate(%Response{} = resp) do
    new_error(:invalid_response, resp)
  end

  defp new_error(reason, %Response{} = resp) when is_atom(reason) do
    {:error, reason, resp}
  end
  defp new_error(reason, status, request) do
    new_error(reason, new(status, %{}, request))
  end
end

defimpl Inspect, for: DgraphEx.Response do
  def inspect(resp, opts) do
    {name, item} = important_item(resp)
    "#DgraphEx.Response<status: #{inspect resp.status}, #{name}: #{inspect item}>"
  end

  defp important_item(%{errors: errors}) when length(errors) > 0 do
    {:errors, errors}
  end
  defp important_item(%{uids: uids}) when map_size(uids) > 0 do
    {:uids, uids}
  end
  defp important_item(%{data: data}) when not is_nil(data) do
    {:data, data}
  end
  defp important_item(%{message: msg}) when is_binary(msg) do
    {:message, msg}
  end

end