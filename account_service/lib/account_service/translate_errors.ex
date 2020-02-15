defmodule AccountService.TranslateErrors do
  @moduledoc false

  @behaviour Absinthe.Middleware

  alias Ecto.Changeset
  alias Absinthe.Adapter.LanguageConventions

  def call(res, _) do
    %{
      res
      | context: Map.delete(res.context, :current_user),
        value:
          res.source
          |> Map.get(:errors, nil)
          |> handle_error(),
        state: :resolved
    }
  end

  defp handle_error({_, error_msg}),
    do: [%{field: nil, message: error_msg}]

  defp handle_error(%Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} ->
      field =
        k
        |> to_string()
        |> LanguageConventions.to_external_name(:field)

      message =
        if is_map(v) do
          v |> Map.values() |> List.first()
        else
          v
        end

      %{field: "#{field}", message: "#{field} #{message}"}
    end)
  end

  defp handle_error(errors) when is_map(errors) do
    Enum.map(errors, fn {key, message} ->
      key
      |> to_string()
      |> LanguageConventions.to_external_name(:field)
      |> (&%{field: &1, message: "#{&1} #{message}"}).()
    end)
  end

  defp handle_error(_), do: []
end
