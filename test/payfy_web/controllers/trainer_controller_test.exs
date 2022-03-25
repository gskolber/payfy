defmodule PayfyWeb.Controllers.TrainerControllerTest do
  use PayfyWeb.ConnCase

  import Payfy.Factory
  alias Payfy.Trainer
  alias Comeonin.Bcrypt

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

        "https://pokeapi.co/api/v2/pokemon/14" ->
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

  describe "create" do
    test "should create a new trainer", %{conn: conn} do
      user = %{
        "user" => %{
          "username" => "valid_user",
          "encrypted_password" => "testando"
        }
      }

      conn = post(conn, Routes.trainer_path(conn, :create), user)
      assert json_response(conn, 200)
    end

    test "should return a error when try use a already claimed username", %{conn: conn} do
      trainer = insert(:trainer)

      user = %{
        "user" => %{
          "username" => trainer.username,
          "encrypted_password" => "testando"
        }
      }

      insert(:trainer, %{username: "test", encrypted_password: "testando"})

      conn = post(conn, Routes.trainer_path(conn, :create), user)
      assert json_response(conn, 400)
    end
  end

  describe "login" do
    test "should return a token when user and password are valid", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      trainer_json = %{
        "username" => trainer.username,
        "password" => "testando"
      }
      conn = post(conn, Routes.trainer_path(conn, :login), trainer_json)
      assert json_response(conn, 200)
    end

    test "should return an error when user does not exists", %{conn: conn} do
      user = %{
        "username" => "inexistant_user",
        "password" => "valid_pass"
      }

      conn = post(conn, Routes.trainer_path(conn, :login), user)
      assert json_response(conn, 401)
    end
  end

  describe "claim_pokemon" do
    test "user should claim a pokemon pikachu", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      {:ok, token} = Trainer.login(trainer.username, "testando")

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post(Routes.trainer_path(conn, :claim_pokemon, "pikachu", %{"authorization" => token}))

      assert json_response(conn, 201)
    end

    test "user receive a error when try claim a inexistent pokemon", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      {:ok, token} = Trainer.login(trainer.username, "testando")

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post(Routes.trainer_path(conn, :claim_pokemon, "saracura", %{"authorization" => token}))

      assert json_response(conn, 404)
    end

    test "should user claim a pokemon by id", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      {:ok, token} = Trainer.login(trainer.username, "testando")

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> post(Routes.trainer_path(conn, :claim_pokemon, "14", %{"authorization" => token}))

      assert json_response(conn, 201)
    end
  end

  describe "feed" do

    test "should trainer feed your pokemon by id", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      {:ok, token} = Trainer.login(trainer.username, "testando")
      pokemon = insert(:new_pokemon, %{trainer_id: trainer.id, hungry: 35})

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> patch(Routes.trainer_path(conn, :feed_pokemon, pokemon.id , %{"authorization" => token}))

      assert json_response(conn, 200)
    end

    test "should return error when pokemon id and user does not match", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      trainer_2 = insert(:trainer)
      {:ok, token} = Trainer.login(trainer.username, "testando")
      pokemon = insert(:new_pokemon, %{trainer_id: trainer_2.id, hungry: 35})

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> patch(Routes.trainer_path(conn, :feed_pokemon, pokemon.id , %{"authorization" => token}))

      assert json_response(conn, 404)
    end
  end

  describe "my_pokemons" do
    test "should return all my pokemons", %{conn: conn} do
      trainer = insert(:trainer, %{encrypted_password: Bcrypt.hashpwsalt("testando")})
      {:ok, token} = Trainer.login(trainer.username, "testando")
      _pokemon_1 = insert(:new_pokemon, %{trainer_id: trainer.id})
      _pokemon_2 = insert(:new_pokemon, %{trainer_id: trainer.id})

      conn = conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> get(Routes.trainer_path(conn, :my_pokemons, %{"authorization" => token}))

      assert json_response(conn, 200)

    end

  end
end
