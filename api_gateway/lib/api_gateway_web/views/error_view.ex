defmodule ApiGatewayWeb.ErrorView do
  use ApiGatewayWeb, :view

  def template_not_found(template, _assigns) do
    %{errors: %{detail: "ERROR"}}
  end
end
