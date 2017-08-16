defmodule DgraphEx.Client do
  alias DgraphEx.{Template, Client}

  @scheme Application.get_env(:dgraph_ex, :scheme, "http")
  @host Application.get_env(:dgraph_ex, :host, "localhost")
  @port Application.get_env(:dgraph_ex, :port, 8080)

  @url %URI{
    scheme: @scheme,
    host:   @host,
    port:   @port,
    path:   "/query",
  } |> to_string

  def send(q, headers \\ [], opts \\ [])
  def send(q, headers, opts) when is_binary(q) do
    case HTTPoison.post(@url, q, headers, opts) do
      {:ok, %{status_code: 200, body: body}} ->
        handle_response(body)
      {:ok, resp} ->
        {:error, resp}
      {:error, _} = err ->
        err
      err ->
        {:error, err}
    end
  end

  def send(%Template{query: ""<>_, variables: %{}} = json_body, headers, opts) do
    with {:ok, body} <- Poison.encode(json_body),
      {:ok, json_resp} <- Client.send(body, [{"Content-Type", "application/json"}] ++ headers, opts)
    do
      {:ok, json_resp}
    else
      {:error, _} = err ->
        err
    end
  end

  defp handle_response(body) when is_binary(body) do
    case Poison.decode(body) do
      {:ok, json} -> handle_response(json)
      err -> err
    end
  end
  defp handle_response(%{"errors" => _} = err) do
    {:error, err}
  end
  defp handle_response(%{"data" => data}) do
    {:ok, data}
  end

end
