defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  alias ApiGateway.{Schema}
  alias ApiGatewayWeb.Endpoint

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: Schema

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: Schema,
            interface: :advanced
  end
end
