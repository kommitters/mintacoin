defmodule MintacoinWeb.RequestParamsTest do
  use MintacoinWeb.ConnCase

  alias MintacoinWeb.RequestParams

  setup do
    %{controller: :accounts, spec_allowed_params: [:email, :name]}
  end

  test "returns just allowed params for given controller", %{
    controller: controller,
    spec_allowed_params: spec_allowed_params
  } do
    %{email: "test@mail.com", name: "Test Name"} =
      allowed_params =
      RequestParams.fetch_allowed(
        %{"email" => "test@mail.com", "name" => "Test Name", "invalid" => "invalid_value"},
        controller
      )

    ^spec_allowed_params = Map.keys(allowed_params)

    nil = Map.get(allowed_params, :invalid)
  end
end
