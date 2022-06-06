defmodule MintacoinWeb.Plugs.AuthenticateTest do
  @moduledoc """
    This module is used to group common tests for the Authenticate Plug module.
  """
  use MintacoinWeb.ConnCase

  import Phoenix.Controller, only: [put_format: 2]
  import Plug.Conn, only: [put_req_header: 3]
  import Mintacoin.Factory

  alias MintacoinWeb.Plugs.Authenticate
  alias Plug.Conn

  @auth_header "authorization"
  @api_key "6aRONqGFFpHq7xDgEvlbDnJURLzdjv/uMeHYQce3KQE"

  setup do
    insert(:minter, api_key: @api_key)
    :ok
  end

  test "ensures that connection successfully passed through the plug", %{conn: conn} do
    conn =
      conn
      |> put_format("json")
      |> put_req_header(@auth_header, "Bearer #{@api_key}")
      |> Authenticate.call(%{})

    %Conn{state: :unset, status: nil} = conn
  end

  test "returns unauthorized response", %{conn: conn} do
    conn =
      conn
      |> put_format("json")
      |> Authenticate.call(%{})

    assert response(conn, 401)
  end
end
