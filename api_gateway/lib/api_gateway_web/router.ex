defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  alias ApiGateway.{Schema}

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug ApiGatewayWeb.Context
  end

  scope "/" do
    pipe_through :api
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug, schema: Schema

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: Schema,
            interface: :advanced
  end
end
