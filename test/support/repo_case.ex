defmodule Payfy.RepoCase do

  @moduledoc """
  This module prepares a RepoCase for testing.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Payfy.Repo

      import Ecto
      import Ecto.Query
      import Payfy.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Payfy.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Payfy.Repo, {:shared, self()})
    end
  end
end
