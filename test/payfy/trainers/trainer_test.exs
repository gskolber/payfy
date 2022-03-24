defmodule Payfy.Trainers.TrainerTest do
  use Payfy.RepoCase

  alias Payfy.Trainers.Trainer
  alias Payfy.Repo
  import Payfy.Factory

  import Assertions, only: [assert_lists_equal: 2]

  setup do
    trainer_attrs = %{
      username: "trainer#{Enum.random(0..2000)}",
      encrypted_password: "password"
    }

    pokemon_attrs = %{
      external_id: Enum.random(0..2000),
      name: "pokemon#{Enum.random(0..2000)}"
    }

    {:ok, %{trainer_attrs: trainer_attrs, pokemon_attrs: pokemon_attrs}}
  end

  describe "new_trainer_changeset/1" do
    test "should create a valid changeset when use valid parameters", %{
      trainer_attrs: trainer_attrs
    } do
      trainer = Trainer.new_trainer_changeset(trainer_attrs)
      assert trainer.valid?
    end

    test "should return a not valid changeset when password is too short", %{
      trainer_attrs: trainer_attrs
    } do
      trainer =
        Trainer.new_trainer_changeset(Map.merge(trainer_attrs, %{encrypted_password: "pass"}))

      refute trainer.valid?
    end

    test "should return a error when username not is a unique constraint", %{
      trainer_attrs: trainer_attrs
    } do
      _trainer =
        Trainer.new_trainer_changeset(trainer_attrs)
        |> Repo.insert()

      {:error, repetead_trainer} =
        Trainer.new_trainer_changeset(trainer_attrs)
        |> Repo.insert()

      refute repetead_trainer.valid?

      username_error = [
        username:
          {"has already been taken",
           [constraint: :unique, constraint_name: "trainer_username_index"]}
      ]

      assert_lists_equal(
        username_error,
        repetead_trainer.errors
      )
    end
  end

  describe "add_pokemon_changeset/2" do
    test "should add a pokemon to trainer", %{pokemon_attrs: pokemon_attrs} do
      {:ok, trainer} = build(:trainer) |> Repo.insert()
      preload_trainer = Repo.preload(trainer, :pokemons)
      trainer_with_pokemon = Trainer.add_pokemon_changeset(preload_trainer, pokemon_attrs)

      assert trainer_with_pokemon.valid?
    end
  end
end
