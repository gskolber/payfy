defmodule Payfy.Trainers.PokemonTest do
  use Payfy.RepoCase

  alias Payfy.Trainers.Pokemon
  import Payfy.Factory

  setup do
    pokemon_attrs = %{
      external_id: Enum.random(0..2000),
      name: "pokemon#{Enum.random(0..2000)}"
    }

    {:ok, %{pokemon_attrs: pokemon_attrs}}
  end

  describe "new_pokemon_changeset/2" do
    test "should create a new pokemon", %{pokemon_attrs: pokemon_attrs} do
      pokemon = Pokemon.new_pokemon_changeset(%Pokemon{}, pokemon_attrs)
      assert pokemon.valid?
    end
  end

  describe "add_hungry_changeset/1" do
    test "should add +1 to pokemon hungry" do
      initial_state_pokemon = insert(:new_pokemon)
      hungry_pokemon = Pokemon.add_hungry_changeset(initial_state_pokemon)

      assert hungry_pokemon.valid?
      assert hungry_pokemon.changes.hungry == 1
    end

    test "should set status to fainted when pokemon hungry is >= 150" do
      initial_state_pokemon = insert(:hungry_pokemon, %{hungry: 149})
      fainted_pokemon = Pokemon.add_hungry_changeset(initial_state_pokemon)

      assert fainted_pokemon.valid?
      assert fainted_pokemon.changes.status == "fainted"
    end
  end

  describe "feed_pokemon_changeset/1" do
    test "should add -20 to pokemon hungry" do
      initial_state_pokemon = insert(:hungry_pokemon, %{hungry: 50})
      fed_pokemon = Pokemon.feed_pokemon_changeset(initial_state_pokemon)

      assert fed_pokemon.valid?
      assert fed_pokemon.changes.hungry == 30
    end

    test "should set hungry to zero when pokemon hungry become <= 0" do
      initial_state_pokemon = insert(:hungry_pokemon, %{hungry: 19})
      fed_pokemon = Pokemon.feed_pokemon_changeset(initial_state_pokemon)

      assert fed_pokemon.valid?
      assert fed_pokemon.changes.hungry == 0
    end
  end
end
