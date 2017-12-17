defmodule DgraphEx.Client do
  alias DgraphEx.{Template, Client}

  def send(params) when is_list(params) do
    request =
      params
      |> Enum.into(%{})
      |> DgraphEx.Request.new
    request
    |> send_request()
    |> DgraphEx.Response.from_http_response(request)
  end

  defp send_request(request) do
    HTTPoison.request(request.method, to_string(request.uri), request.body, request.headers, request.http_options)
  end

  def send(%Template{query: ""<>_, variables: %{}} = json_body, headers, opts) do
    with {:ok, body} <- Poison.encode(json_body),
      {:ok, json_resp} <- Client.send(body: body, headers: [{"Content-Type", "application/json"}] ++ headers, http_options: opts)
    do
      {:ok, json_resp}
    else
      {:error, _} = err ->
        err
    end
  end

end
