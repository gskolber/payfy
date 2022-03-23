defmodule Payfy.Repo.Migrations.AddPokemons do
  use Ecto.Migration

  def change do
    create table(:pokemon) do
      add :external_id, :integer
      add :name, :string
      timestamps()
    end
  end
end
