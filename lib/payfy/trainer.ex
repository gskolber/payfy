defmodule Payfy.Trainer do
  @moduledoc """
  This module is the main aggration of the pokemon functions.
  """

  alias Payfy.Services.PokemonService
  alias Payfy.Trainers.Pokemon
  alias Payfy.Trainers.Trainer
  alias Payfy.Repo
  alias Comeonin.Bcrypt
  alias Payfy.Guardian

  def assign_pokemon(name, user) do
    PokemonService.get_pokemon(name)
    |> normalize_pokemon()
    |> Pokemon.new_pokemon_changeset()
  end

  defp normalize_pokemon(pokemon) do
    %{
      external_id: pokemon["id"],
      name: pokemon["name"],
      types: pokemon["types"]
    }
  end

  def create_trainer(fields) do
    Trainer.new_trainer_changeset(fields) |> Repo.insert()
  end

  def get_trainer(id) do
    Repo.get(Trainer, id)
  end

  def login(username, password) do
    case Repo.get_by(Trainer, username: username) |> Bcrypt.check_pass(password) do
      {:ok, user} ->
        {:ok, token, _} = Guardian.encode_and_sign(user)
        token
      _ ->
        {:error, :not_found}
    end
  end
end
