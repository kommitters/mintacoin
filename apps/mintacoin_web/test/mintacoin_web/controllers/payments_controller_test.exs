defmodule MintacoinWeb.PaymentsControllerTest do
  use MintacoinWeb.ConnCase

  import Mintacoin.Factory

  alias Mintacoin.{Minter, Asset, Account}
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

    test "returns errors when data is invalid", %{
      conn: conn
    } do
      conn = post(conn, Routes.payments_path(conn, :create), %{})

      %{
        "errors" => %{
          "source" => ["can't be blank"],
          "destination" => ["can't be blank"],
          "asset_code" => ["can't be blank"],
          "amount" => ["can't be blank"]
        }
      } = json_response(conn, 422)
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

      %{"errors" => %{"source" => ["does not exist"]}} = json_response(conn, 422)
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

    test "returns errors when the source is not valid", %{
      conn: conn,
      creation_params: creation_params
    } do
      conn =
        post(conn, Routes.payments_path(conn, :create), %{
          creation_params
          | source: "invalid-id"
        })

      %{"errors" => %{"source" => ["source must be an uuid"]}} = json_response(conn, 422)
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
          | asset_code: "bad_code"
        })

      %{"errors" => %{"asset_code" => ["does not exist"]}} = json_response(conn, 422)
    end
  end

  describe "retrieve payment" do
    test "returns payment with valid given id", %{conn: conn} do
      %{
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
  end

  defp payment_params(_conn) do
    %Account{address: source} = insert(:account)
    %Account{address: destination} = insert(:account)

    %Asset{code: asset_code} = insert(:asset)

    creation_params = %{
      source: source,
      destination: destination,
      asset_code: asset_code,
      amount: "10.0"
    }

    %{creation_params: creation_params}
  end
end
