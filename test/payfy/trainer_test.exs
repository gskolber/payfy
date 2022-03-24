defmodule Payfy.TrainerTest do
  use ExUnit.Case
  use Payfy.RepoCase

  alias Payfy.Trainer
  alias Payfy.Trainers.Pokemon
  alias Payfy.Repo
  import Payfy.Factory


  import Assertions, only: [assert_lists_equal: 2]

  setup do
    Tesla.Mock.mock(fn env ->
      case env.url do
        "https://pokeapi.co/api/v2/pokemon/pikachu" ->
          %Tesla.Env{
            status: 200,
            body: %{
              "id" => 25,
              "name" => "pikachu"
            }
          }

        "https://pokeapi.co/api/v2/pokemon/squirtle" ->
          %Tesla.Env{
            status: 200,
            body: %{
              "id" => 14,
              "name" => "squirtle"
            }
          }

        "https://pokeapi.co/api/v2/pokemon/saracura" ->
          %Tesla.Env{status: 404}

        _ ->
          %Tesla.Env{status: 404, body: "NotFound"}
      end
    end)

    :ok
  end

  describe "claim_pokemon/2" do
    test "should trainer claim the pokemon" do
      trainer = insert(:trainer)
      assert {:ok, trainer_with_pokemon} = Trainer.claim_pokemon("pikachu", trainer)
      last_claimed = List.last(trainer_with_pokemon.pokemons)
      assert last_claimed.name == "pikachu"
      assert last_claimed.external_id == 25
    end

    test "should return error not found when pokemon does not exists" do
      assert {:error, :not_found} == Trainer.claim_pokemon("saracura", insert(:trainer))
    end
  end

  describe "my_pokemons/1" do
    test "should return the trainer's pokemons" do
      trainer = insert(:trainer)
      assert {:ok, _trainer_with_pokemon} = Trainer.claim_pokemon("pikachu", trainer)
      assert {:ok, trainer_with_pokemon} = Trainer.claim_pokemon("squirtle", trainer)

      trainer_preload = Repo.preload(trainer_with_pokemon, :pokemons)
      assert_lists_equal(trainer_preload.pokemons, Trainer.my_pokemons(trainer))
    end

    test "should return empty list when trainer has no pokemons" do
      trainer = insert(:trainer) |> Repo.preload(:pokemons)
      assert_lists_equal(trainer.pokemons, Trainer.my_pokemons(trainer))
    end
  end

  describe "create_trainer/1" do
    test "should create a trainer" do
      trainer = %{username: "trainer#{Enum.random(0..2000)}", encrypted_password: "password"}
      assert {:ok, _trainer} = Trainer.create_trainer(trainer)
    end

    test "should returns a error when password is too short" do
      trainer = %{username: "trainer#{Enum.random(0..2000)}", encrypted_password: "pass"}
      assert {:error, changeset} = Trainer.create_trainer(trainer)

      expected_errors = [
        encrypted_password:
          {"should be at least %{count} character(s)",
           [count: 8, validation: :length, kind: :min, type: :string]}
      ]

      assert_lists_equal(expected_errors, changeset.errors)
    end
  end

  describe "get_trainer/1" do
    test "should return a trainer when id exists" do
      trainer = insert(:trainer)
      assert trainer == Trainer.get_trainer(trainer.id)
    end

    test "should return nil when id does not exists" do
      assert nil == Trainer.get_trainer(Enum.random(0..2000))
    end
  end

  describe "login/2" do
    test "should return ok and token when username and password are valid" do
      trainer = %{username: "trainer#{Enum.random(0..2000)}", encrypted_password: "password"}
      {:ok, created_trainer} = Trainer.create_trainer(trainer)

      assert {:ok, _token} = Trainer.login(created_trainer.username, trainer.encrypted_password)
    end

    test "should return error when user and password does not match" do
      trainer = %{username: "trainer#{Enum.random(0..2000)}", encrypted_password: "password"}
      {:ok, created_trainer} = Trainer.create_trainer(trainer)

      assert {:error, :not_found} = Trainer.login(created_trainer.username, "ANY_PASSWORD")
    end
  end

  describe "update_hungry/1" do
    test "should update hungry" do
      poke_1 = insert(:new_pokemon, %{hungry: 10})
      poke_2 = insert(:new_pokemon, %{hungry: 78})

      list_of_pokemon = [poke_1, poke_2]

      Trainer.update_hungry(list_of_pokemon)

      updated_poke_1 = Repo.get(Pokemon, poke_1.id)
      updated_poke_2 = Repo.get(Pokemon, poke_2.id)

      assert updated_poke_1.hungry == 11
      assert updated_poke_2.hungry == 79
    end
  end

  describe "feed_pokemon/2" do
    test "should feed the pokemon if status are healthy" do
      trainer = insert(:trainer)
      pokemon = insert(:new_pokemon, %{trainer_id: trainer.id, hungry: 35})

      {:ok, pokemon_after_good_berries, message} = Trainer.feed_pokemon(pokemon.id, trainer)

      assert pokemon_after_good_berries.hungry == 15
      assert message == "Thank you for feeding me senpai. Pikapi"
      assert pokemon_after_good_berries.status == "healthy"
    end

    test "hungry should does not reduce if hungry is greater than 150" do
      trainer = insert(:trainer)
      pokemon = insert(:new_pokemon, %{trainer_id: trainer.id, hungry: 169})

      {:ok, pokemon_after_good_berries, _message} = Trainer.feed_pokemon(pokemon.id, trainer)

      assert pokemon_after_good_berries.hungry == 169
    end
  end
end
