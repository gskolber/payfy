defmodule Payfy.Repo.Migrations.AddUniqueIndexes do
  use Ecto.Migration

  def change do
    create index(:pokemon, :name, unique: true)
    create index(:trainer, :username, unique: true)
  end
end
