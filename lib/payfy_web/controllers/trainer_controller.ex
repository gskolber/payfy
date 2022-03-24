defmodule PayfyWeb.Controllers.TrainerController do
  use PayfyWeb, :controller

  alias Payfy.Trainer

  def create(conn, %{"user" => user}) do
    case Trainer.create_trainer(user) do
      {:ok, user} ->
        json(
          conn,
          %{
            "status" => :ok,
            "user" => user
          }
        )

      {:error, error} ->
        json(
          conn,
          %{
            "status" => :error,
            "error" => error
          }
        )
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    case Trainer.login(username, password) do
      {:ok, token} ->
        conn
        |> json(%{
          "authorization" => token
        })

      {:error, :not_found} ->
        Process.sleep(1000)

        conn
        |> json(%{
          "status" => :error,
          "error" => :user_not_found
        })
    end
  end

  def claim_pokemon(conn, %{"pokemon" => pokemon}) do
    trainer = Guardian.Plug.current_resource(conn)

    case Trainer.claim_pokemon(pokemon, trainer) do
      {:ok, pokemon} ->
        json(
          conn,
          %{
            "status" => :ok,
            "message" => "Pokemon claimed",
            "data" => pokemon
          }
        )

      {:error, error} ->
        json(
          conn,
          %{
            "status" => :error,
            "error" => error
          }
        )
    end
  end

  def feed_pokemon(conn, %{"id_pokemon" => pokemon_id}) do
    trainer = Guardian.Plug.current_resource(conn)
    {:ok, pokemon, message} = Trainer.feed_pokemon(pokemon_id, trainer)

    conn
    |> json(
      %{
        "status" => :ok,
        "message" => message,
        "data" => pokemon
      }
    )
  end

  def my_pokemons(conn, _) do
    trainer = Guardian.Plug.current_resource(conn)
    pokemons = Trainer.my_pokemons(trainer)
    conn
    |> json(
      %{
        "status" => :ok,
        "data" => pokemons
      }
    )
  end

  def search_pokemon(conn, _) do
    trainer = Guardian.Plug.current_resource(conn)

    case Trainer.search_pokemon(trainer) do
      {:ok, trainer} ->
        searched_pokemon = List.first(trainer.pokemons)
        json(
          conn,
          %{
            "status" => :ok,
            "message" => "You find a wild #{searched_pokemon.name}",
            "data" => searched_pokemon
          }
        )

      {:error, error} ->
        json(
          conn,
          %{
            "status" => :error,
            "error" => error
          }
        )
    end
  end

end
