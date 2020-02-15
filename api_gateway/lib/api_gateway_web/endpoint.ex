defmodule ApiGatewayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api_gateway

  @session_options [
    store: :cookie,
    key: "_api_gateway_key",
    signing_salt: "28zD9+Kr"
  ]

  socket "/socket", ApiGatewayWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug Plug.Static,
    at: "/",
    from: :api_gateway,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ApiGatewayWeb.Router
end
