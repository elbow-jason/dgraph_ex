defmodule DgraphEx.ChangesetTest do
  use ExUnit.Case
  doctest DgraphEx.Changeset

  alias DgraphEx.Changeset

  alias DgraphEx.ModelPerson, as: Person


  test "a changeset defaults to invalid" do
    assert Changeset.is_valid?(%Changeset{}) == false
  end

  test "an instantiated changeset has nil as errors" do
    cs = %Changeset{}
    assert cs |> Map.has_key?(:errors)
    assert cs.errors == nil
  end

  test "a changeset that has run and has no errors is valid" do
    assert Changeset.is_valid?(%Changeset{errors: []}) == true
  end

  test "cast extracts changes and model into plain old maps, and module to module" do
    assert Changeset.cast(%Person{}, %{name: "Bleep", age: 34}, [:name, :age]) == %Changeset{
      module:   Person,
      model:    %{name: nil, age: nil, works_at: nil, _uid_: nil},
      changes:  %{name: "Bleep", age: 34},
      errors:   [],
    }
  end

  test "uncast applies changes of a changeset to the model of the changeset and returns a struct of that model" do
    result =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34}, [:name, :age])
      |> Changeset.uncast
    assert result == {:ok, %Person{
      name:   "Bleep",
      age:    34,
      _uid_:  nil,
    }}
  end

  test "cast only allows changes that are in the allowed_fields list" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34, unwanted_field: true}, [:name, :age])
    # unwanted_field is removed
    assert cs.changes ==  %{name: "Bleep", age: 34}
    assert !Map.has_key?(cs.changes, :unwanted_field)
  end

  test "validate_required appends no errors when required fields are present" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34}, [:name, :age])
      |> Changeset.validate_required([:name, :age])
    assert cs.errors == []
  end

  test "validate_required appends errors when required fields are not present" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep"}, [:name, :age])
      |> Changeset.validate_required([:name, :age])
  
    assert !Map.has_key?(cs.changes, :age)
    assert cs.errors == [{:age, :cannot_be_nil}]
  end

  test "validate_type appends no errors when valid types are encountered" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34}, [:name, :age])
      |> Changeset.validate_type(:name, :string)
      |> Changeset.validate_type(:age, :int)
    assert cs.errors == []
  end

  test "validate_type appends errors when invalid types are encountered" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34}, [:name, :age])
      |> Changeset.validate_type(:name, :geo)
    assert cs.errors == [{:name, :invalid_geo}]
  end

  test "validate_type can handle a list of doubles with {:key, type} (keywords)" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: "Bleep", age: 34}, [:name, :age])
      |> Changeset.validate_type(name: :geo, age: :float)
    assert cs.errors == [age: :invalid_float, name: :invalid_geo]
  end

  test "validate_type can handle a list with atoms (lookup done on model's fields)" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: :nope, age: :nope}, [:name, :age])
      |> Changeset.validate_type([:name, :age])
    assert cs.errors == [age: :invalid_int, name: :invalid_string]
  end

  test "validate_type can handle a mixed list of atoms and keywords" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: :nope, age: :nope}, [:name, :age])
      |> Changeset.validate_type([:name, age: :float])
    assert cs.errors == [age: :invalid_float, name: :invalid_string]
  end


  test "validate_type can handle a mixed list of atoms and keywords with lists as values" do
    cs =
      %Person{}
      |> Changeset.cast(%{name: :nope, age: :nope}, [:name, :age])
      |> Changeset.validate_type([:name, age: [:int, :float]])
    assert cs.errors == [age: :invalid_type, name: :invalid_string]
  end

  test "uncasting with errors returns an error tuple" do
    result =
      %Person{}
      |> Changeset.cast(%{name: :nope, age: :nope}, [:name, :age])
      |> Changeset.validate_type([:name, age: [:int, :float]])
      |> Changeset.uncast()
    
    assert result ==  {:error, %DgraphEx.Changeset{
      changes: %{age: :nope, name: :nope},
      errors: [age: :invalid_type, name: :invalid_string],
      model: %{_uid_: nil, age: nil, name: nil, works_at: nil},
      module: DgraphEx.ModelPerson
    }}
  end

  test "validate_child can validate a child/submodel correctly" do
  end
end