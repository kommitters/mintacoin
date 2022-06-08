defmodule MintacoinWeb.Utils.RequestParamsTest do
  use MintacoinWeb.ConnCase

  alias MintacoinWeb.Utils.RequestParams

  setup do
    %{
      test_params: %{
        "email" => "test@mail.com",
        "name" => "Test Name",
        "invalid" => "invalid_value"
      }
    }
  end

  describe "with valid resource" do
    setup do
      %{
        resource: :accounts,
        expected_params: %{email: "test@mail.com", name: "Test Name"}
      }
    end

    test "returns just allowed params", %{
      test_params: test_params,
      resource: resource,
      expected_params: expected_params
    } do
      ^expected_params = RequestParams.fetch_allowed(test_params, resource)
    end

    test "ignores non allowed params", %{
      test_params: test_params,
      resource: resource
    } do
      nil =
        test_params
        |> RequestParams.fetch_allowed(resource)
        |> Map.get(:invalid)
    end
  end

  describe "with invalid resource" do
    setup do
      %{
        resource: :invalid_resource,
        expected_params: %{}
      }
    end

    test "returns empty map", %{
      test_params: test_params,
      resource: resource,
      expected_params: expected_params
    } do
      ^expected_params = RequestParams.fetch_allowed(test_params, resource)
    end
  end
end
