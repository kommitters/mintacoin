defmodule MintacoinWeb.Plugs.ValidateSignatureTest do
  @moduledoc """
    This module is used to group common tests for the ValidateSignature Plug module.
  """
  use MintacoinWeb.ConnCase

  import Phoenix.Controller, only: [put_format: 2]
  import Mintacoin.Factory

  alias Mintacoin.Account
  alias MintacoinWeb.Plugs.ValidateSignature
  alias Plug.Conn

  setup %{conn: conn} do
    %Account{address: source, signature: signature} =
      insert(:account,
        signature: "0Qmk3ZinGhZLuIMJC2j/WNN+scV3MMLxkI5ALlAVun8",
        derived_key: "30MGLHU1OGC23O06RFSHSA5325O49V05UEFA81FMN8JHV0AUVKG0"
      )

    %{
      conn: conn,
      source: source,
      signature: signature
    }
  end

  test "ensures that the source address and signature passed successfuly through the plug", %{
    conn: conn,
    source: source,
    signature: signature
  } do
    conn =
      conn
      |> Map.merge(%{params: %{"source" => source, "signature" => signature}})
      |> put_format("json")
      |> ValidateSignature.call(%{})

    %Conn{state: :unset, status: nil} = conn
  end

  test "returns bad request response", %{conn: conn} do
    conn =
      conn
      |> put_format("json")
      |> ValidateSignature.call(%{})

    assert response(conn, 400)
  end
end
