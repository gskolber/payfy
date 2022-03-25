defmodule PayfyWeb.TrainerController do
  use PayfyWeb, :controller

  alias PayfyWeb.ErrorHelpers
  alias Payfy.Trainer

  def create(conn, %{"user" => user}) do
    case Trainer.create_trainer(user) do
      {:ok, user} ->
        conn
        |> put_resp_content_type("application/json")
        |> put_status(:ok)
        |> render("show.json", %{trainer: user})

      {:error, error} ->
        conn
        |> put_status(400)
        |> json(%{
          data: %{
            status: "error",
            error: ErrorHelpers.translate_errors(error)
          }
        })
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
        |> put_status(401)
        |> json(%{
          "status" => :error,
          "error" => :user_not_found
        })
    end
  end

  def claim_pokemon(conn, %{"pokemon" => pokemon}) do
    trainer = Guardian.Plug.current_resource(conn)

    case Trainer.claim_pokemon(pokemon, trainer) do
      {:ok, trainer} ->
        last_claim = List.first(trainer.pokemons)

        conn
        |> put_status(:created)
        |> render("new_pokemon.json", %{pokemon: last_claim})

      {:error, _} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          data: %{
            status: "error",
            message: "Pokemon not found"
          }
        })
    end
  end

  def feed_pokemon(conn, %{"id_pokemon" => pokemon_id}) do
    trainer = Guardian.Plug.current_resource(conn)

    case Trainer.feed_pokemon(pokemon_id, trainer) do
      {:ok, pokemon, _message} ->
        conn
        |> put_status(:ok)
        |> render("pokemon.json", %{trainer: pokemon})

      _ ->
        conn
        |> put_status(404)
        |> json(%{
          data: %{
            status: "error",
            message: "Pokemon not found"
          }
        })
    end
  end

  def my_pokemons(conn, _) do
    trainer = Guardian.Plug.current_resource(conn)
    pokemons = Trainer.my_pokemons(trainer)

    conn
    |> put_status(200)
    |> render("pokemons.json", %{pokemons: pokemons, message: "Your pokemons"})
  end

  def search_pokemon(conn, _) do
    trainer = Guardian.Plug.current_resource(conn)

    case Trainer.search_pokemon(trainer) do
      {:ok, trainer} ->
        searched_pokemon = List.first(trainer.pokemons)

        conn
        |> put_status(200)
        |> render("new_pokemon.json", %{pokemon: searched_pokemon})

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
