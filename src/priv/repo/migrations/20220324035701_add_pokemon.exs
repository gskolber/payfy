defmodule Payfy.Repo.Migrations.AddPokemons do
  use Ecto.Migration

  def change do
    create table(:pokemon) do
      add :external_id, :integer
      add :name, :string
      add :hungry, :integer
      add :status, :string
      add :trainer_id, references(:trainer)
      timestamps()
    end
  end
end
