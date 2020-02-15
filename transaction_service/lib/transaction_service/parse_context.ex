defmodule TransactionService.ParseContext do
  @behaviour Absinthe.Middleware

  def call(%{state: :unresolved} = res, _opts) do
    ctx = res.context

    id = get_in(ctx, ["current_user", "id"])

    %{res | context: %{current_user: %{id: id}}}
  end

  def call(res, _), do: res
end
