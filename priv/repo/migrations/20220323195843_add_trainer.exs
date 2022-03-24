defmodule Payfy.Repo.Migrations.AddTrainer do
  use Ecto.Migration

  def change do
    create table(:trainer) do
      add :username, :string
      add :encrypted_password, :string
      timestamps()
    end

    create index(:trainer, :username, unique: true)
  end
end
