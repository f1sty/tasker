defmodule TaskerWeb.Router do
  use TaskerWeb, :router

  alias TaskerWeb.Plug.Auth

  pipeline :manager_api do
    plug :accepts, ["json"]
    plug Auth, allowed_user_types: ["manager"]
  end

  pipeline :driver_api do
    plug :accepts, ["json"]
    plug Auth, allowed_user_types: ["driver"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Auth, allowed_user_types: ["driver", "manager"]
  end

  scope "/api", TaskerWeb do
    pipe_through :api
    resources "/tasks", TaskController, only: [:show]
  end

  scope "/api", TaskerWeb do
    pipe_through :manager_api
    resources "/tasks", TaskController, only: [:create, :delete]
  end

  scope "/api", TaskerWeb do
    pipe_through :driver_api
    resources "/tasks", TaskController, only: [:index, :update]
  end
end
