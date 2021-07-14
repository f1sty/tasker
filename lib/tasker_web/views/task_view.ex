defmodule TaskerWeb.TaskView do
  @moduledoc false

  use TaskerWeb, :view

  def render("tasks.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, __MODULE__, "task.json")}
  end

  def render("task.json", %{task: task}) do
    Tasker.transform_coordinates(task)
  end
end
