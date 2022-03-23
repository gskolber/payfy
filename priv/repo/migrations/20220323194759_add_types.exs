defmodule Payfy.Repo.Migrations.AddTypes do
  use Ecto.Migration

  def change do
    create table(:type) do
      add :name, :string
      timestamps()
    end
  end
end
