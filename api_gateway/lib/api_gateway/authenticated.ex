defmodule ApiGateway.Authenticated do
  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = res, _opts) do
    if Map.get(res.context, :current_user, nil) do
      res
    else
      Absinthe.Resolution.put_result(res, {
        :error,
        "Not Authenticated"
      })
    end
  end

  def call(res, _), do: res
end
