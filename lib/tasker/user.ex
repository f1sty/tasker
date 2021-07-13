defmodule Tasker.User do
  use Ecto.Schema
  import Ecto.Changeset

  @types_mapping %{
    0 => "manager",
    1 => "driver"
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :type, :integer
    has_one :token, Tasker.Token
    has_many :tasks, Tasker.Task

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> validate_inclusion(:type, Map.keys(@types_mapping))
  end
end
