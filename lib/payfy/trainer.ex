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

  @doc """
  Used to claim a Pokemon. With this function we can claim a Pokemon by id or name
  using PokeApi
  """
  def claim_pokemon(name, trainer) do
    case PokemonService.get_pokemon(name) do
      {:ok, pokemon} ->
        new_pokemon =
          pokemon
          |> normalize_pokemon()
          |> save_pokemon

        update_trainer = Repo.preload(trainer, :pokemons)

        Trainer.add_pokemon_changeset(update_trainer, new_pokemon) |> Repo.update()

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  defp save_pokemon(pokemon) do
    {:ok, new_pokemon} =
      Pokemon.new_pokemon_changeset(%Pokemon{}, pokemon)
      |> Repo.insert()

    new_pokemon
  end

  defp normalize_pokemon(pokemon) do
    %{
      external_id: pokemon["id"],
      name: pokemon["name"]
    }
  end

  @doc """
  Return the list of pokemons of a trainer
  """

  def my_pokemons(trainer) do
    trainer =
      trainer
      |> Repo.preload(:pokemons)

    trainer.pokemons
  end

  @doc """
  Create a Trainer login and password
  """
  def create_trainer(fields) do
    case Trainer.new_trainer_changeset(fields) |> Repo.insert() do
      {:ok, trainer} ->
        {:ok, Repo.preload(trainer, :pokemons)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Return a trainer by id
  """

  def get_trainer(id) do
    Repo.get(Trainer, id)
  end

  @doc """
  Validate a user and generate a token
  """
  def login(username, password) do
    case Repo.get_by(Trainer, username: username) |> Bcrypt.check_pass(password) do
      {:ok, user} ->
        {:ok, token, _} = Guardian.encode_and_sign(user)
        {:ok, token}

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Add hungry++ in each pokemon of the list
  """
  def update_hungry(list_of_pokemons) do
    list_of_pokemons
    |> Enum.each(fn %{id: id} ->
      Repo.get(Pokemon, id)
      |> Pokemon.add_hungry_changeset()
      |> Repo.update()
    end)
  end

  @doc """
  Feed a pokemon. This function will reduce -20 hungry to the pokemon
  """
  def feed_pokemon(pokemon_id, trainer) do
    pokemon = Repo.get(Pokemon, pokemon_id)

    with true <- not is_nil(pokemon),
         true <- trainer_is_owner?(trainer, pokemon) do
      {:ok, pokemon} =
        Pokemon.feed_pokemon_changeset(pokemon)
        |> Repo.update()

      {:ok, pokemon, hungry_message(pokemon)}
    else
      _ ->
        {:error, :not_found}
    end
  end

  defp trainer_is_owner?(trainer, pokemon) do
    trainer.id == pokemon.trainer_id
  end

  defp hungry_message(pokemon) do
    case pokemon.status do
      "healthy" ->
        "Thank you for feeding me senpai. Pikapi"

      "fainted" ->
        "Does mom in heaven have bread? and fainted out..."
    end
  end

  @doc """
  Used to search a random pokemon
  """
  def search_pokemon(trainer) do
    {:ok, number_of_pokemons} = PokemonService.get_number_of_pokemons()
    pokemon = Enum.random(0..number_of_pokemons)
    claim_pokemon(Integer.to_string(pokemon), trainer)
  end
end
