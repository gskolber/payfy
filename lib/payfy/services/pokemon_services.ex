defmodule Payfy.Services.PokemonService do
  @moduledoc """
  PokemonService is a module that provides pokemon services.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://pokeapi.co/api/v2"
  plug Tesla.Middleware.JSON

  @success_status 200

  def get_pokemon(name) do
    with {:ok, response} <- get("pokemon/#{name}"),
         @success_status <- response.status do
      Map.take(response.body, ["id", "name", "types"])
    else
      404 -> {:error, :not_found}
    end
  end
end
