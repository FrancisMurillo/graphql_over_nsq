defmodule ApiGatewayWeb.Context do
  @behaviour Plug

  alias Plug.Conn

  alias ApiGateway.{AccountClient}

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)

    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    %{
      current_user: get_current_user(conn)
    }
  end

  defp get_current_user(conn) do
    conn
    |> Conn.get_req_header("authorization")
    |> List.first()
    |> case do
      "Bearer " <> email ->
        AccountClient.get_by_email(email)

      _ ->
        nil
    end
  end
end
