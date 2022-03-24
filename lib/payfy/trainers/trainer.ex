defmodule Payfy.Trainers.Trainer do
  @moduledoc """
  Trainer is a module that handles the trainers.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Payfy.Trainers.Pokemon
  alias Comeonin.Bcrypt

  @derive {Jason.Encoder, only: [:username, :pokemons]}
  schema "trainer" do
    field :username, :string
    field :encrypted_password, :string
    has_many :pokemons, Pokemon
    timestamps()
  end

  def new_trainer_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:username, :encrypted_password])
    |> validate_length(:encrypted_password, min: 8)
    |> unique_constraint(:username)
    |> validate_required([:username, :encrypted_password])
    |> update_change(:encrypted_password, &Bcrypt.hashpwsalt/1)
  end

  def add_pokemon_changeset(trainer, pokemon) do
    trainer
    |> change()
    |> put_assoc(:pokemons, [pokemon | trainer.pokemons])
  end
end
