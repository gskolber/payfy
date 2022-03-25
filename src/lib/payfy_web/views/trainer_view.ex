defmodule PayfyWeb.TrainerView do
  use PayfyWeb, :view

  alias PayfyWeb.TrainerView

  def render("show.json", %{trainer: trainer}) do
    %{
      data: render_one(trainer, TrainerView, "trainer.json")
    }
  end

  def render("trainer.json", %{trainer: trainer}) do
    %{
      name: trainer.username,
      pokemon: render_many(trainer.pokemons, TrainerView, "pokemon.json")
    }
  end

  def render("pokemons.json", %{pokemons: pokemons}) do
    %{
      pokemons: render_many(pokemons, TrainerView, "pokemon.json")
    }
  end

  def render("new_pokemon.json", %{pokemon: pokemon}) do
    %{
      message: "Wow! You just claimed a new pokemon!",
      external_id: pokemon.external_id,
      name: pokemon.name,
      hungry: pokemon.hungry,
      status: pokemon.status
    }
  end

  def render("pokemon.json", %{trainer: pokemon}) do
    %{
      id: pokemon.id,
      external_id: pokemon.external_id,
      name: pokemon.name,
      hungry: pokemon.hungry,
      status: pokemon.status
    }
  end
end
