defmodule DgraphEx.Client do
  alias DgraphEx.{Template, Client}

  @scheme Application.get_env(:dgraph_ex, :scheme, "http")
  @host   Application.get_env(:dgraph_ex, :host, "localhost")
  @port   Application.get_env(:dgraph_ex, :port, 8080)
  @path   "/query"
  @method :post

  def send(params) when is_list(params) do
    body    = Keyword.get(params, :body, "")
    method  = Keyword.get(params, :method, :post)
    headers = Keyword.get(params, :headers, [])
    options = Keyword.get(params, :options, [])
    uri = %URI{
      scheme: Keyword.get(params, :scheme, @scheme),
      host:   Keyword.get(params, :host,   @host),
      port:   Keyword.get(params, :port,   @port),
      path:   Keyword.get(params, :path,   @path),
    }
    case HTTPoison.request(method, to_string(uri), body, headers, options) do
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
      {:ok, json_resp} <- Client.send(body: body, headers: [{"Content-Type", "application/json"}] ++ headers, options: opts)
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

  def do_send_request(method, url, body, headers, options) do

  end

end
