defmodule Payfy.Trainers.Pokemon do
  @moduledoc """
  Simple pokemon struct
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Payfy.Trainers.Trainer

  schema "pokemon" do
    field :external_id, :integer
    field :name, :string
    field :hungry, :integer, default: 0
    field :status, :string, default: "healthy"
    belongs_to :trainer, Trainer
    timestamps()
  end

  def new_pokemon_changeset(pokemon, attrs) do
    pokemon
    |> cast(attrs, [:external_id, :name])
  end

  def add_hungry_changeset(pokemon) do
    pokemon
    |> change()
    |> put_change(:hungry, pokemon.hungry + 1)
    |> check_pokemon_hungry()
  end

  defp check_pokemon_hungry(changeset) do
    if changeset.changes.hungry >= 150 do
      put_change(changeset, :status, "fainted")
    else
      changeset
    end
  end

  def feed_pokemon_changeset(pokemon) do
    pokemon
    |> change()
    |> feed_pokemon()
  end

  defp feed_pokemon(changeset) when changeset.data.hungry < 150 do
    if changeset.data.hungry - 20 >= 0 do
      put_change(changeset, :hungry, changeset.data.hungry - 20)
    else
      put_change(changeset, :hungry, 0)
    end
  end

  defp feed_pokemon(changeset) do
    changeset
  end
end
