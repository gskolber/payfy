defmodule Payfy.Trainer.Pokemon do
  @moduledoc """
  Simple pokemon struct
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Payfy.Trainer.Types

  schema "pokemon" do
    field :external_id, :integer
    field :name, :string
    many_to_many :types, Types, join_through: "pokemon_types"

    timestamps()
  end

  def new_pokemon_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:external_id, :name, :types])
  end
end
