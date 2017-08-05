defmodule DgraphEx do
  alias DgraphEx.{
    Field,
    Mutation,
    MutationSet,
    MutationSchema,
  }
  defstruct [
    sequence: [],
    vars: [],
    args: [],
    label: 1,
    template: nil,
  ]

  defp put_sequence(%DgraphEx{sequence: prev_sequence} = d, prefix) when is_list(prefix) do
    %{ d | sequence: prefix ++ prev_sequence }
  end
  defp put_sequence(%DgraphEx{sequence: sequence} = d, item) do
    %{ d | sequence: [ item | sequence ]  }
  end

  defp put_arg(%DgraphEx{} = d, fields) when is_list(fields) do
    Enum.reduce(fields, d, fn field, acc_d -> put_arg(acc_d, field) end)
  end
  defp put_arg(%DgraphEx{} = d, %Field{label: label, type: type}) do
    put_arg(d, label, type)
  end
  defp put_arg(%DgraphEx{args: prev_args} = d, label, type) do
    %{ d | args: [ {label, type} | prev_args ] }
  end

  defp put_var(%DgraphEx{} = d, %Field{label: label, object: object}) do
    put_var(d, label, object)
  end
  defp put_var(%DgraphEx{} = d, fields) when is_list(fields) do
    Enum.reduce(fields, d, fn field, acc_d -> put_var(acc_d, field) end)
  end
  defp put_var(%DgraphEx{vars: prev_vars} = d, label, object) do
    %{ d | vars: [ {label, object} | prev_vars ] }
  end

  def new() do
    %DgraphEx{}
  end

  def mutation(%DgraphEx{} = d) do
    put_sequence(d, :mutation)
  end
  
  def schema(%DgraphEx{} = d) do
    put_sequence(d, :schema)
  end

  def set(%DgraphEx{} = d) do
    put_sequence(d, :set)
  end

  def field(%DgraphEx{} = d , subject, predicate, object, type) do
    {label, d} = next_label(d)
    the_field = %Field{
      subject: subject,
      predicate: predicate,
      object: object,
      type: type,
      label: label,
    }
    d
    |> put_arg(label, type)
    |> put_var(label, object)
    |> put_sequence(the_field)
  end
  def model(%DgraphEx{} = d, subject, %{__struct__: _} = model) do
    subject 
    |> DgraphEx.Vertex.populate_fields(model)
    |> Enum.map(fn field ->
      %{ field | label: Field.dollarify(field) }
    end)
    |> Enum.reduce(d, fn (field, acc_d) ->
      acc_d
      |> put_arg(field)
      |> put_var(field)
      |> put_sequence(field)
    end)
  end
  def assemble(%DgraphEx{sequence: sequence}) do
    sequence
    |> Enum.reverse
    |> assemble
  end
  def assemble([]) do
    []
  end
  def assemble([:mutation | _ ] = sequence) do
    assemble(sequence, %Mutation{})
  end
  def assemble([:mutation, :set, %Field{} = field | rest], %Mutation{} = mutation) do
    assemble([:mutation, :set | rest], Mutation.put_set(mutation, field))
  end
  def assemble([:mutation, :set | rest], %Mutation{} = mutation) do
    assemble([:mutation | rest], mutation)
  end
  def assemble([:mutation | rest ], %Mutation{} = mutation) do
    case [mutation | assemble(rest)] do
      [alone] -> alone
      x when length(x) > 1 -> x
    end
  end

  # def render_template(%DgraphEx{sequence: sequence}) do
  #   sequence
  #   |> Enum.reverse
  #   |> do_render([], [], :template)
  # end
  # def render(%DgraphEx{sequence: seq}) do
  #   seq
  #   |> Enum.reverse
  #   |> do_render([], [], :raw)
  # end
  def render(%{__struct__: module} = block) do
    module.render(block)
  end

  # defp do_render([], pre, post, _) do
  #   (pre |> Enum.reverse |> Enum.join(" ")) <> (post |> Enum.join(" "))
  # end
  # defp do_render([{:mutation, mutations } | rest], pre, post, mode) do
  #   do_render(rest, [ do_render(mutations, [], [], mode), " mutation {" | pre ], [ " } " | post ], mode)
  # end
  # defp do_render([{:set, sets} | rest], pre, post, mode) do
  #   do_render(rest, [ do_render(sets, [], [], mode), " set { " | pre ], [ " } " | post ], mode)
  # end
  # defp do_render([%Field{} = field | rest], pre, post, mode = :raw) do
  #   do_render(rest, [ Field.as_setter(field) | pre ], post, mode)
  # end
  # defp do_render([%Field{} = field | rest], pre, post, mode = :template) do
  #   do_render(rest, [ Field.as_setter_template(field) | pre ], post, mode)
  # end

  defp next_label(%DgraphEx{label: label} = d) do
    {"$#{label}", %{ d | label: label + 1 } }
  end

  def query(template) do
    template
    |> DgraphEx.Client.send
  end
  def query(template, variables) when is_list(variables) do
    query(template, variables |> Enum.into(%{}))
  end
  def query(template, variables) when is_binary(template) and is_map(variables) do
    variables
    |> DgraphEx.Template.prepare(template)
    |> DgraphEx.Client.send
  end

end
