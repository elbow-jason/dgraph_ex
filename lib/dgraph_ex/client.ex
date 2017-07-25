defmodule DgraphEx.Client do
  alias DgraphEx.{Template, Client}

  @scheme Application.get_env(:dgraph_ex, :scheme, "http")
  @host Application.get_env(:dgraph_ex, :host, "localhost")
  @port Application.get_env(:dgraph_ex, :port, 8080)

  if is_nil(@host) do
    raise %CompileError{
      description: "DgraphEx config requires a :host"
    }
  end

  use Slogger, level: Application.get_env(:dgraph_ex, :log_level, :debug)

  @url %URI{
    scheme: @scheme,
    host:   @host,
    port:   @port,
    path:   "/query",
  } |> to_string

  def send(q, headers \\ [], opts \\ [])
  def send(q, headers, opts) when is_binary(q) do
    Slogger.debug("DgraphEx => querying #{@url} with => \n#{q}")
    case HTTPoison.post(@url, q, headers, opts) do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode(body)
      {:ok, resp} ->
        {:error, resp}
      {:error, _} = err -> 
        err
      err ->
        Slogger.error("Dgraph.Client Error. Got: #{inspect err}")
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


end