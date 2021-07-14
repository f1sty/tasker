defmodule TaskerWeb.Plug.Auth do
  @moduledoc """
  This Plug used to authorize users
  """
  use TaskerWeb, :controller

  @secret Application.compile_env(:tasker, :token_secret)

  def init(opts), do: opts

  def call(conn, opts) do
    allowed_user_types = Keyword.get(opts, :allowed_user_types)

    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        authorize(conn, token, allowed_user_types)

      _ ->
        unauthorized(conn)
    end
  end

  defp authorize(conn, value, allowed_user_types) do
    case Phoenix.Token.verify(TaskerWeb.Endpoint, @secret, value) do
      {:ok, %{user_type: user_type}} ->
        token = Tasker.get_token_by_value(value)

        if token && user_type in allowed_user_types do
          do_authorize(conn, token)
        else
          unauthorized(conn)
        end

      _ ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(TaskerWeb.ErrorView)
    |> render("401.json")
    |> halt()
  end

  defp do_authorize(conn, token) do
    assign(conn, :user_id, token.user_id)
  end
end
