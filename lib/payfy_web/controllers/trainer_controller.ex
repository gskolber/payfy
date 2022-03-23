defmodule PayfyWeb.Controllers.TrainerController do
  use PayfyWeb, :controller

  alias Payfy.Trainer

  def create(conn, %{"user" => user}) do
    IO.inspect(user)

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
end
