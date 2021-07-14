defmodule Tasker.Factory do
  alias Geo.Point
  alias Tasker.{User, Token}
  alias Tasker.Task, as: T

  @srid 4326
  @secret Application.compile_env(:tasker, :token_secret)

  def build(:task) do
    %T{pickup: location(), delivery: location()}
  end

  def build(:user, user_type) do
    %User{token: build(:token, user_type)}
  end

  def build(:token, user_type) do
    %Token{value: token(user_type)}
  end

  def build(factory_name, attrs) do
    factory_name |> build() |> struct!(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    factory_name |> build(attrs) |> Tasker.Repo.insert!()
  end

  defp token(user_type) do
    Phoenix.Token.sign(TaskerWeb.Endpoint, @secret, %{user_type: user_type})
  end

  defp location do
    %Point{coordinates: {longitude(), latitude()}, srid: @srid}
  end

  def latitude, do: Enum.random(-90..90)
  def longitude, do: Enum.random(-180..180)
end
