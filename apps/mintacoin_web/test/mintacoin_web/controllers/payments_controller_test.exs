defmodule MintacoinWeb.PaymentsControllerTest do
  use MintacoinWeb.ConnCase

  import Mintacoin.Factory

  alias Mintacoin.{Minter, Asset, Account, Payment}
  alias Ecto.UUID

  @auth_header "authorization"

  setup %{conn: conn} do
    %Minter{api_key: api_key} = insert(:minter)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header(@auth_header, "Bearer #{api_key}")

    %{
      conn: conn
    }
  end

  describe "create payments" do
    setup [:payment_params]

    test "returns payment when data is valid", %{
      conn: conn,
      creation_params:
        %{source: source, destination: destination, asset_code: asset_code, amount: amount} =
          creation_params
    } do
      conn = post(conn, Routes.payments_path(conn, :create), creation_params)

      %{
        "resource" => "payment",
        "source" => ^source,
        "destination" => ^destination,
        "asset_code" => ^asset_code,
        "amount" => ^amount
      } = json_response(conn, 201)
    end

    test "returns errors when data is invalid except for the source and signature", %{
      conn: conn,
      creation_params: %{source: source, signature: signature}
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{source: source, signature: signature})

      %{
        "errors" => %{
          "destination" => ["can't be blank"],
          "asset_code" => ["can't be blank"],
          "amount" => ["can't be blank"]
        }
      } = json_response(conn, 422)
    end

    test "returns errors when data is invalide", %{
      conn: conn
    } do
      conn = post(conn, Routes.payments_path(conn, :create), %{})

      %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "returns errors when the source doesn't exist", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | source: UUID.generate()
        })

      %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "returns errors when the destination doesn't exist", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | destination: UUID.generate()
        })

      %{"errors" => %{"destination" => ["does not exist"]}} = json_response(conn, 422)
    end

    test "returns errors when the source is invalid", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | source: "invalid-id"
        })

      %{"errors" => %{"detail" => "Bad Request"}} = json_response(conn, 400)
    end

    test "returns errors when the destination is invalid", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | destination: "invalid-id"
        })

      %{"errors" => %{"destination" => ["destination must be an uuid"]}} =
        json_response(conn, 422)
    end

    test "returns errors when the code doesn't exist", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | asset_code: "MTK:123"
        })

      %{"errors" => %{"asset_code" => ["does not exist"]}} = json_response(conn, 422)
    end
  end

  describe "retrieve payment" do
    test "returns payment with valid given id", %{conn: conn} do
      %Payment{
        id: payment_id,
        source: source,
        destination: destination,
        asset_code: asset_code,
        amount: amount
      } = insert(:payment)

      conn = get(conn, Routes.payments_path(conn, :show, payment_id))

      %{
        "resource" => "payment",
        "source" => ^source,
        "destination" => ^destination,
        "asset_code" => ^asset_code,
        "amount" => ^amount
      } = json_response(conn, 200)
    end

    test "returns errors when given id doesn't exist", %{conn: conn} do
      conn = get(conn, Routes.payments_path(conn, :show, UUID.generate()))

      %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end

    test "returns errors when given id is invalid", %{conn: conn} do
      conn = get(conn, Routes.payments_path(conn, :show, "invalid"))

      %{"errors" => %{"detail" => "Not Found"}} = json_response(conn, 404)
    end
  end

  defp payment_params(_conn) do
    %Account{address: source, signature: source_signature} =
      insert(:account,
        signature: "0Qmk3ZinGhZLuIMJC2j/WNN+scV3MMLxkI5ALlAVun8",
        derived_key: "30MGLHU1OGC23O06RFSHSA5325O49V05UEFA81FMN8JHV0AUVKG0"
      )

    %Account{address: destination} = insert(:account)

    %Asset{code: asset_code} = insert(:asset)

    creation_params = %{
      source: source,
      destination: destination,
      asset_code: asset_code,
      amount: "10.0",
      signature: source_signature
    }

    %{creation_params: creation_params}
  end
end
