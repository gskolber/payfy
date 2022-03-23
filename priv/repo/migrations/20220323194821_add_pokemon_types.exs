defmodule Payfy.Repo.Migrations.AddPokemonTypes do
  use Ecto.Migration

  def change do
    create table(:pokemon_types) do
      add :pokemon_id, references(:pokemon)
      add :type_id, references(:type)
      timestamps()
    end

    create unique_index(:pokemon_types, [:pokemon_id, :type_id])
  end
end
