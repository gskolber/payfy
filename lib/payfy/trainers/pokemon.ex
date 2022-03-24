defmodule Payfy.Trainers.Pokemon do
  @moduledoc """
  Simple pokemon struct
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Payfy.Trainers.Trainer

  @derive {Jason.Encoder, only: [:name, :trainers]}
  schema "pokemon" do
    field :external_id, :integer
    field :name, :string
    many_to_many :trainers, Trainer, join_through: "trainer_pokemons"
    timestamps()
  end

  def new_pokemon_changeset(pokemon, attrs) do
    pokemon
    |> cast(attrs, [:external_id, :name])
  end
end
