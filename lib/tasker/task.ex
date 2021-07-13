defmodule Tasker.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses_mapping %{
    0 => "new",
    1 => "assigned",
    2 => "done"
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :delivery, :string
    field :pickup, :string
    field :status, :integer, default: 0
    belongs_to :user, Tasker.User

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:pickup, :delivery, :status, :user_id])
    |> validate_required([:pickup, :delivery, :status])
    |> validate_inclusion(:status, Map.keys(@statuses_mapping))
  end
end
