defmodule TaskerWeb.TaskController do
  @moduledoc false

  use TaskerWeb, :controller
  action_fallback TaskerWeb.FallbackController

  def index(conn, %{"lat" => lat, "lon" => lon} = params) do
    IO.inspect(params)
    location = %{"lat" => String.to_integer(lat), "lon" => String.to_integer(lon)}
    IO.inspect(location)
    tasks = Tasker.list_tasks(location)

    render(conn, "tasks.json", tasks: tasks)
  end

  def create(conn, %{"task" => task}) do
    with {:ok, task} <- Tasker.create_task(task) do
      render(conn, "task.json", task: task)
    end
  end

  def show(conn, %{"id" => id} = params) do
    IO.inspect(params)
    task = Tasker.get_task!(id)

    render(conn, "task.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => attrs}) do
    task = Tasker.get_task!(id)

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
