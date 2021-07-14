defmodule Tasker.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Geo.PostGIS.Geometry

  @derive {Jason.Encoder, except: [:__meta__, :user]}

  @statuses ~w[new assigned done]a

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tasks" do
    field :delivery, Geometry
    field :pickup, Geometry
    field :status, Ecto.Enum, values: @statuses, default: :new
    belongs_to :user, Tasker.User

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:pickup, :delivery])
    |> validate_required([:pickup, :delivery])
  end

  @doc """
  Allows driver to apply for the task and change it's status.
  """
  def update_changeset(task, attrs) do
    task
    |> cast(attrs, [:status, :user_id])
    |> validate_required([:status, :user_id])
    |> validate_inclusion(:status, tl(@statuses))
  end
end
