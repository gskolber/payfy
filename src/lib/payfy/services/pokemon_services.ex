defmodule Payfy.Services.PokemonService do
  @moduledoc """
  PokemonService is a module that provides pokemon services.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://pokeapi.co/api/v2"
  plug Tesla.Middleware.JSON

  @success_status 200

  def get_pokemon(name) do
    with {:ok, response} <- get("/pokemon/#{String.downcase(name)}"),
         @success_status <- response.status do
      {:ok, Map.take(response.body, ["id", "name"])}
    else
      404 -> {:error, :not_found}
      _ -> {:error, :unknown}
    end
  end

  def get_number_of_pokemons() do
    with {:ok, response} <- get("/pokemon/"),
         @success_status <- response.status do
      {:ok, response.body["count"]}
    else
      404 -> {:error, :not_found}
      _ -> {:error, :unknown}
    end
  end
end
