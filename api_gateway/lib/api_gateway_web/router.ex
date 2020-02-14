defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  alias ApiGateway.Schema

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: MyAppWeb.Schema

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: Schema,
            interface: :advanced
  end
end
