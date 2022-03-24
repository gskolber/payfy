defmodule PayfyWeb.Router do
  use PayfyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :maybe_browser_auth do
    plug(Guardian.Plug.Pipeline, module: Payfy.Guardian)
    plug(Guardian.Plug.VerifySession)
    plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
    plug(Guardian.Plug.LoadResource)
  end

  scope "/api", PayfyWeb do
    pipe_through :api

    post "/register", Controllers.TrainerController, :create
    post "/login", Controllers.TrainerController, :login

    scope "/auth", Controllers do
      pipe_through [:maybe_browser_auth]

      post "/claim/:pokemon", TrainerController, :claim_pokemon
      post "/feed/:id_pokemon", TrainerController, :feed_pokemon
      get "/my_pokemons", TrainerController, :my_pokemons
      get "/search", TrainerController, :search_pokemon
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: PayfyWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
