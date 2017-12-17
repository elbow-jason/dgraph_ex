defmodule DgraphEx.Request do
  alias DgraphEx.Request

  @scheme Application.get_env(:dgraph_ex, :scheme, "http")
  @host   Application.get_env(:dgraph_ex, :host, "localhost")
  @port   Application.get_env(:dgraph_ex, :port, 8080)
  # @path   "/query"
  @method :post

  defstruct [
    data:         nil,
    method:       nil,
    uri:          nil,
    body:         nil,
    headers:      [],
    http_options: [],
  ]

  @doc """
  when passed a map the list must have :body as a string or
  :data as a renderable struct AND must have a :path as a string
  or :data as a renderable struct that has a `path/0` function
  that returns a string
  """
  def new(%{data: %module{} = data} = params) do
    uri = %URI{
      scheme: Map.get(params, :scheme, @scheme),
      host:   Map.get(params, :host,   @host),
      port:   Map.get(params, :port,   @port),
      path:   Map.get(params, :path, false) || module.path(),
    }
    %Request{
      data:           data,
      method:         Map.get(params, :method, :post),
      uri:            uri,
      body:           Map.get(params, :body, module.render(data)),
      headers:        Map.get(params, :headers, []),
      http_options:   Map.get(params, :http_options, []),
    }
  end


end