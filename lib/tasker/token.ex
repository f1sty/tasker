defmodule Tasker.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tokens" do
    field :value, :string
    belongs_to :user, Tasker.User

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:value])
    |> validate_required([:value])
    |> assoc_constraint(:users)
  end
end
