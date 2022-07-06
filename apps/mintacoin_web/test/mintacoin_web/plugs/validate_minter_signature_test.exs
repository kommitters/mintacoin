defmodule MintacoinWeb.Plugs.ValidateMinterSignatureTest do
  @moduledoc """
    This module is used to group common tests for the ValidateMinterSignature Plug module.
  """

  use MintacoinWeb.ConnCase

  import Phoenix.Controller, only: [put_format: 2]
  import Mintacoin.Factory

  alias Mintacoin.Account
  alias MintacoinWeb.Plugs.ValidateMinterSignature
  alias Plug.Conn

  @api_key "6aRONqGFFpHq7xDgEvlbDnJURLzdjv/uMeHYQce3KQE"
  @email "test@gmail.com"

  setup %{conn: conn} do
    %Account{signature: signature} =
      insert(:account,
        email: @email,
        signature: "0Qmk3ZinGhZLuIMJC2j/WNN+scV3MMLxkI5ALlAVun8",
        derived_key: "30MGLHU1OGC23O06RFSHSA5325O49V05UEFA81FMN8JHV0AUVKG0"
      )

    minter = insert(:minter, email: @email, api_key: @api_key)

    %{
      conn: conn,
      minter: minter,
      signature: signature
    }
  end

  test "ensures that the minter signature corresponds to the minter in the assigns and passed successfuly through the plug",
       %{
         conn: conn,
         minter: minter,
         signature: signature
       } do
    conn =
      conn
      |> put_format("json")
      |> Map.merge(%{params: %{"signature" => signature}, assigns: %{minter: minter}})
      |> ValidateMinterSignature.call(%{})

    %Conn{state: :unset, status: nil} = conn
  end

  test "returns bad request response if the minter doesn't exist", %{
    conn: conn,
    signature: signature
  } do
    conn =
      conn
      |> put_format("json")
      |> Map.merge(%{params: %{"signature" => signature}})
      |> ValidateMinterSignature.call(%{})

    assert response(conn, 400)
  end

  test "returns bad request response if the minter signature doesn't exist", %{
    conn: conn,
    minter: minter
  } do
    conn =
      conn
      |> put_format("json")
      |> Map.merge(%{assigns: %{minter: minter}})
      |> ValidateMinterSignature.call(%{})

    assert response(conn, 400)
  end

  test "returns bad request response if there is not signature and minter", %{conn: conn} do
    conn =
      conn
      |> put_format("json")
      |> ValidateMinterSignature.call(%{})

    assert response(conn, 400)
  end
end
