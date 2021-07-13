defmodule Tasker.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION postgis"

    create table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pickup, :string
      add :delivery, :string
      add :status, :integer
      add :user_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps()
    end

    create index(:tasks, [:user_id, :pickup])
  end
end
