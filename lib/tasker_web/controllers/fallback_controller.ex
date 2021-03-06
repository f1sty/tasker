defmodule TaskerWeb.FallbackController do
  @moduledoc false
  use TaskerWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(TaskerWeb.ErrorView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(TaskerWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> put_view(TaskerWeb.ErrorView)
    |> render(:"400")
  end

  # def call(conn, {:error, :unauthorized}) do
  #   conn
  #   |> put_status(:unauthorized)
  #   |> put_view(TaskerWeb.ErrorView)
  #   |> render(:"401")
  # end
end
