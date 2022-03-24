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


  def claim_pokemon(name, trainer) do
    case PokemonService.get_pokemon(name) do
      {:ok, pokemon} ->
        new_pokemon = pokemon
        |> normalize_pokemon()
        |> check_if_pokemon_exists

        update_trainer = Repo.preload(trainer, :pokemons)

      Trainer.add_pokemon_changeset(update_trainer, new_pokemon) |> Repo.update()
    end
  end

  defp check_if_pokemon_exists(pokemon) do
    case Repo.get_by(Pokemon, external_id: pokemon.external_id) do
      nil ->
        {:ok, new_pokemon} = Pokemon.new_pokemon_changeset(%Pokemon{}, pokemon)
        |> Repo.insert()
        new_pokemon
      pokemon ->
        pokemon
    end
  end

  defp normalize_pokemon(pokemon) do
    %{
      external_id: pokemon["id"],
      name: pokemon["name"]
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
