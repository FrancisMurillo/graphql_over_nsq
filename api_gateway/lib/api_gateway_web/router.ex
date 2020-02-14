defmodule ApiGatewayWeb.Router do
  use ApiGatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApiGatewayWeb do
    pipe_through :api
  end
end
