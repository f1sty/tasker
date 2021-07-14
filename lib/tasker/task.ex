defmodule Tasker.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Geo.PostGIS.Geometry

  @derive {Jason.Encoder, except: [:__meta__, :user]}

  @statuses_mapping %{
    0 => "new",
    1 => "assigned",
    2 => "done"
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :delivery, Geometry
    field :pickup, Geometry
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

  @doc """
  Allows driver to apply for the task and change it's status.
  """
  def update_changeset(task, attrs) do
    task
    |> cast(attrs, [:status, :user_id])
    |> validate_required([:status, :user_id])
    |> validate_inclusion(:status, Map.keys(@statuses_mapping))
  end
end
