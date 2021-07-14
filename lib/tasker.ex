defmodule Tasker do
  @moduledoc false

  import Ecto.Query
  import Geo.PostGIS

  alias Geo.Point
  alias Tasker.{Repo, Token}
  alias Tasker.Task, as: T

  def list_tasks, do: Repo.all(T)

  def list_nearby_tasks(:error), do: {:error, :bad_request}

  def list_nearby_tasks(attrs) do
    {first, location} = Map.pop(attrs, "first", 10)
    location = parse_location(location)

    tasks =
      from(task in T,
        where: is_nil(task.user_id),
        where: task.status == "new",
        select: {st_distance_in_meters(task.pickup, ^location), task},
        limit: ^first
      )
      |> Repo.all()
      |> sort_by_distance_asc()
      |> remove_distance()

    {:ok, tasks}
  end

  def create_task(attrs) do
    attrs = parse_coordinates(attrs)

    %T{}
    |> T.changeset(attrs)
    |> Repo.insert()
  end

  def get_task!(id) do
    Repo.get!(T, id)
  end

  def update_task(%T{} = task, attrs) do
    task
    |> T.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%T{} = task) do
    Repo.delete(task)
  end

  def get_token_by_value(token_value) do
    from(token in Token, where: ^token_value == token.value) |> Repo.one()
  end

  defp sort_by_distance_asc(tasks) do
    Enum.sort(tasks, &(elem(&1, 0) <= elem(&2, 0)))
  end

  defp remove_distance(tasks) do
    Enum.map(tasks, fn {_distance, task} -> task end)
  end

  # TODO: maybe move to some kind of utils module

  def transform_coordinates(%T{pickup: pickup, delivery: delivery} = task) do
    pickup = transform_location(pickup)
    delivery = transform_location(delivery)

    %{task | pickup: pickup, delivery: delivery}
  end

  def transform_location(%Point{coordinates: {lon, lat}}), do: %{lat: lat, lon: lon}

  def parse_coordinates(%{"pickup" => pickup, "delivery" => delivery} = attrs) do
    pickup = parse_location(pickup)
    delivery = parse_location(delivery)

    Map.merge(attrs, %{"pickup" => pickup, "delivery" => delivery})
  end

  def parse_coordinates(attrs), do: attrs

  def parse_location(%{"lat" => latitude, "lon" => longitude}) do
    %Point{coordinates: {longitude, latitude}, srid: 4326}
  end
end
