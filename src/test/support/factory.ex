defmodule Payfy.Factory do

  @moduledoc """
  Factory for creating trainers and pokemons.

  Documentation in: https://github.com/thoughtbot/ex_machina
  """

  use ExMachina.Ecto, repo: Payfy.Repo

  alias Payfy.Trainers.Trainer
  alias Payfy.Trainers.Pokemon

  def trainer_factory do
    %Trainer{
      username: "trainer#{Enum.random(0..2000)}",
      encrypted_password: "password"
    }
  end

  def new_pokemon_factory do
    %Pokemon{
      external_id: Enum.random(0..2000),
      name: "pokemon#{Enum.random(0..2000)}"
    }
  end

  def hungry_pokemon_factory do
    %Pokemon{
      external_id: Enum.random(0..2000),
      name: "pokemon#{Enum.random(0..2000)}",
      hungry: 149
    }
  end
end
