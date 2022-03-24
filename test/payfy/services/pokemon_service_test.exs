defmodule Payfy.Services.PokemonServiceTest do
  use ExUnit.Case

  alias Payfy.Services.PokemonService

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

        "https://pokeapi.co/api/v2/pokemon/saracura" ->
          %Tesla.Env{status: 404}

        "https://pokeapi.co/api/v2/pokemon/" ->
          %Tesla.Env{
            status: 200,
            body: %{
              "count" => 321
            }
          }

        _ ->
          %Tesla.Env{status: 404, body: "NotFound"}
      end
    end)

    :ok
  end

  describe "get_pokemon/1" do
    test "should return pikachu info" do
      assert {:ok, pokemon} = PokemonService.get_pokemon("pikachu")
      assert pokemon["id"] == 25
      assert pokemon["name"] == "pikachu"
    end

    test "should return error when pokemon does not exists" do
      assert {:error, :not_found} = PokemonService.get_pokemon("saracura")
    end
  end

  describe "get_number_of_pokemons/0" do
    test "should return the correct number of pokemons" do
      assert {:ok, number_of_pokemons} = PokemonService.get_number_of_pokemons()
      assert number_of_pokemons == 321
    end
  end
end
