defmodule DgraphEx do
  alias DgraphEx.{
    Query,
  }

  require DgraphEx.Vertex
  DgraphEx.Vertex.query_model()
  use DgraphEx.Field
  use DgraphEx.Expr

  use Query
  use Query.Mutation
  use Query.Schema
  use Query.Var
  use Query.As
  use Query.MutationSet
  use Query.Func
  use Query.Filter
  use Query.Block

end
  # Mutation,
  # Schema,
  # As,
  # Func,
  # MutationSet,
  # MutationSchema,

  # defstruct [
  #   blocked: true,
  #   sequence: [],
  #   vars: [],
  #   args: [],
  #   label: 1,
  #   template: nil,
  # ]

  # defp put_sequence(%DgraphEx{sequence: prev_sequence} = d, prefix) when is_list(prefix) do
  #   %{ d | sequence: prefix ++ prev_sequence }
  # end
  # defp put_sequence(%DgraphEx{sequence: sequence} = d, item) do
  #   %{ d | sequence: [ item | sequence ]  }
  # end

  # defp blocked(%DgraphEx{} = d, bool) do
  #   %{ d | blocked: bool } 
  # end



  # def mutation(%DgraphEx{} = d) do
  #   d
  #   |> blocked(false)
  #   |> put_sequence(:mutation)
  # end


  # def schema(%DgraphEx{} = d) do
  #   d
  #   |> blocked(false)
  #   |> put_sequence(:schema)
  # end

  # def var(%DgraphEx{} = d) do
  #   d
  #   |> blocked(true)
  #   |> put_sequence(:var)
  # end

  # def as(%DgraphEx{} = d, identifier) do
  #   put_sequence(d, {:as, identifier})
  # end

  # def set(%DgraphEx{} = d) do
  #   put_sequence(d, :set)
  # end

  # def func(%DgraphEx{} = d, name, expr, block) do
  #   put_sequence(d, %Func{
  #     name:   name,
  #     expr:   expr,
  #     block:  block,
  #   })
  # end

  # def count(value) when is_atom(value) do
  #   %Expr.Count{value: value}
  # end

  # def eq(label, value, type) when is_atom(label) do
  #   %Expr.Eq{
  #     label:  label,
  #     value:  value,
  #     type:   type,
  #   }
  # end




  # def render(%{__struct__: module} = block) do
  #   module.render(block)
  # end



  # defp next_label(%DgraphEx{label: label} = d) do
  #   {"$#{label}", %{ d | label: label + 1 } }
  # end


  # def query(template) do
  #   template
  #   |> DgraphEx.Client.send
  # end
  # def query(template, variables) when is_list(variables) do
  #   query(template, variables |> Enum.into(%{}))
  # end
  # def query(template, variables) when is_binary(template) and is_map(variables) do
  #   variables
  #   |> DgraphEx.Template.prepare(template)
  #   |> DgraphEx.Client.send
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

  # def render_template(%DgraphEx{sequence: sequence}) do
  #   sequence
  #   |> Enum.reverse
  #   |> do_render([], [], :template)
  # end


  # defp put_arg(%DgraphEx{} = d, fields) when is_list(fields) do
  #   Enum.reduce(fields, d, fn field, acc_d -> put_arg(acc_d, field) end)
  # end
  # defp put_arg(%DgraphEx{} = d, %Field{label: label, type: type}) do
  #   put_arg(d, label, type)
  # end
  # defp put_arg(%DgraphEx{args: prev_args} = d, label, type) do
  #   %{ d | args: [ {label, type} | prev_args ] }
  # end

  # defp put_var(%DgraphEx{} = d, %Field{label: label, object: object}) do
  #   put_var(d, label, object)
  # end
  # defp put_var(%DgraphEx{} = d, fields) when is_list(fields) do
  #   Enum.reduce(fields, d, fn field, acc_d -> put_var(acc_d, field) end)
  # end
  # defp put_var(%DgraphEx{vars: prev_vars} = d, label, object) do
  #   %{ d | vars: [ {label, object} | prev_vars ] }
  # end


