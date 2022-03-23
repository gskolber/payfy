defmodule Payfy.Trainers.Types do
  @moduledoc """
  This module is the representation of the types of a pokemon.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Payfy.Trainers.Pokemon

  @derive {Jason.Encoder, only: [:name]}
  schema "types" do
    field :name, :string
    many_to_many :pokemon, Pokemon, join_through: "pokemon_types"

    timestamps()
  end

  def new_type_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name])
  end
end
