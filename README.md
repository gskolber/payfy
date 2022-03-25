# Payfy

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

Running via docker:
  * Build the image `docker-compose build`
  * Create an alias to run Elixir commands `alias mix="docker-compose run --rm phoenix mix"`
  * Create the database `mix ecto.create`
  * Make migrations `mix ecto.migrate`
  * Start the application `docker-compose up`

## Endpoint Documentation

Import the file `Collection-Postman.json` in postman.
## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
  * Guide to Docker & Elixir enviroment: https://medium.com/swlh/use-docker-to-create-an-elixir-phoenix-development-environment-e1a81def1d2e
