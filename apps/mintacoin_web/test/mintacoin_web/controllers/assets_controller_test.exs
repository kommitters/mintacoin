defmodule MintacoinWeb.AssetsControllerTest do
  use MintacoinWeb.ConnCase

  import Mintacoin.Factory, only: [insert: 1, insert: 2]

  alias Ecto.Adapters.SQL.Sandbox
  alias Mintacoin.{Repo, Blockchains, Blockchain, Minter, Account}
  alias Blockchains.Network

  @auth_header "authorization"

  setup %{conn: conn} do
    :ok = Sandbox.checkout(Repo)

    # Create default blockchain
    {:ok, %Blockchain{id: blockchain_id}} = Blockchains.create(%{name: Network.name()})

    %Minter{id: minter_id, email: email, name: name, api_key: api_key} = insert(:minter)
    %Account{address: address} = insert(:account, email: email, name: name)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header(@auth_header, "Bearer #{api_key}")

    code = "ASSET_CODE"

    %{
      conn: conn,
      address: address,
      minter_id: minter_id,
      blockchain_id: blockchain_id,
      actual_asset_code: "#{code}:#{address}",
      attrs: %{
        "code" => code,
        "supply" => "1000000",
        "blockchain" => Network.name()
      }
    }
  end

  describe "create asset" do
    test "returns asset when data is valid", %{
      conn: conn,
      attrs:
        %{
          "supply" => supply
        } = attrs,
      minter_id: minter_id,
      blockchain_id: blockchain_id,
      actual_asset_code: actual_asset_code
    } do
      conn = post(conn, Routes.assets_path(conn, :create), attrs)

      %{
        "resource" => "asset",
        "code" => ^actual_asset_code,
        "supply" => ^supply,
        "minter_id" => ^minter_id,
        "blockchain_id" => ^blockchain_id
      } = json_response(conn, 201)
    end

    test "returns errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.assets_path(conn, :create), %{})

      %{
        "errors" => %{
          "code" => ["can't be blank"],
          "supply" => ["can't be blank"]
        }
      } = json_response(conn, 422)
    end
  end

  describe "retrieve asset" do
    setup %{conn: conn, attrs: attrs} do
      asset = post(conn, Routes.assets_path(conn, :create), attrs) |> json_response(201)

      %{
        asset: asset
      }
    end

    test "returns asset with given code", %{
      conn: conn,
      asset: asset
    } do
      ^asset =
        conn
        |> get(Routes.assets_path(conn, :show, asset["code"]))
        |> json_response(200)
    end

    test "returns 404 when asset does not exist", %{
      conn: conn
    } do
      %{"errors" => %{"detail" => "Not Found"}} =
        conn
        |> get(Routes.assets_path(conn, :show, "INVALID_CODE:123"))
        |> json_response(404)
    end
  end

  describe "list minter's assets" do
    setup %{conn: conn, attrs: attrs} do
      asset1 = post(conn, Routes.assets_path(conn, :create), attrs) |> json_response(201)

      asset2 =
        attrs
        |> Map.put("code", "ASSET_CODE2")
        |> (&post(conn, Routes.assets_path(conn, :create), &1)).()
        |> json_response(201)

      %{
        assets: [asset1, asset2]
      }
    end

    test "returns minter's assets", %{
      conn: conn,
      assets: assets
    } do
      ^assets =
        conn
        |> get(Routes.assets_path(conn, :index))
        |> json_response(200)
    end
  end
end
