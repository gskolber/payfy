defmodule Payfy.Repo.Migrations.AddTrainer do
  use Ecto.Migration

  def change do
    create table(:trainer) do
      add :username, :string
      add :encrypted_password, :string
      timestamps()
    end

    create table(:trainer_pokemons) do
      add :trainer_id, references(:trainer)
      add :pokemon_id, references(:pokemon)
    end

    create unique_index(:trainer_pokemons, [:trainer_id, :pokemon_id])
  end
end
