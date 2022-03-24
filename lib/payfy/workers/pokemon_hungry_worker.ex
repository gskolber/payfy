defmodule Payfy.Workers.PokemonHungryWorker do
  use Oban.Worker
  import Ecto.Query
  alias Payfy.Repo
  alias Payfy.Trainer

  @impl Oban.Worker
  def perform(_job) do
    query =
      from pk in "pokemon",
        where: pk.hungry <= 150,
        select: %{id: pk.id, hungry: pk.hungry}

    Repo.all(query)
    |> update_hungry()

    :ok
  end

  defp update_hungry(list_of_pokemons) do
    list_of_pokemons |> Trainer.update_hungry()
  end
end
