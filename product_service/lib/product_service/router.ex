defmodule ProductService.Router do
  use Plug.Router

  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)

  forward("/graphql",
    to: Absinthe.Plug,
    init_opts: [schema: ProductService.Schema]
  )

  forward("/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [schema: ProductService.Schema, interface: :advanced]
  )

  plug(:dispatch)
end
