defmodule TaskerWeb.TaskController do
  @moduledoc false

  use TaskerWeb, :controller
  action_fallback TaskerWeb.FallbackController

  def index(conn, %{"lat" => lat, "lon" => lot, "first" => first}) do
    attrs =
      with {lat, _} <- Float.parse(lat),
           {lon, _} <- Float.parse(lot),
           {first, _} <- Integer.parse(first) do
        %{"lat" => lat, "lon" => lon, "first" => first}
      end

    with {:ok, tasks} <- Tasker.list_nearby_tasks(attrs) do
      render(conn, "tasks.json", tasks: tasks)
    end
  end

  def index(conn, _params) do
    tasks = Tasker.list_tasks()

    render(conn, "tasks.json", tasks: tasks)
  end

  def create(conn, %{"task" => task}) do
    with {:ok, task} <- Tasker.create_task(task) do
      render(conn, "task.json", task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Tasker.get_task!(id)

    render(conn, "task.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => attrs}) do
    task = Tasker.get_task!(id)
    attrs = Map.merge(attrs, %{"user_id" => conn.assigns.user_id}) |> IO.inspect()

    with {:ok, task} <- Tasker.update_task(task, attrs) do
      render(conn, "task.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Tasker.get_task!(id)

    with {:ok, _task} <- Tasker.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
