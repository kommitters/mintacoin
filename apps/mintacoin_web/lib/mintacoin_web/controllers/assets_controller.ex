defmodule MintacoinWeb.AssetsController do
  use MintacoinWeb, :controller

  alias Ecto.Changeset
  alias MintacoinWeb.Utils.RequestParams
  alias Mintacoin.{Asset, Assets, Blockchain, Blockchains}

  @type params :: map()
  @type conn :: Plug.Conn.t()
  @type status :: :ok | :created
  @type template :: String.t()
  @type error :: :not_found | Changeset.t()

  action_fallback MintacoinWeb.FallbackController

  @spec index(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def index(conn, _params) do
    minter_id = conn.assigns[:minter].id

    assets =
      case Assets.list_by_minter_id(minter_id) do
        {:ok, assets} -> assets
        {:error, _error} -> []
      end

    conn
    |> put_status(:ok)
    |> render("index.json", assets: assets)
  end

  @spec create(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def create(conn, params) do
    minter_id = conn.assigns[:minter].id

    params
    |> RequestParams.fetch_allowed(:assets)
    |> Map.put(:minter_id, minter_id)
    |> fetch_blockchain_id()
    |> Assets.create()
    |> handle_response(conn, :created, "asset.json")
  end

  @spec show(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def show(conn, %{"code" => code}) do
    code
    |> Assets.retrieve_by_code()
    |> handle_response(conn, :ok, "asset.json")
  end

  defp fetch_blockchain_id(%{blockchain: blockchain_name} = params) do
    case Blockchains.retrieve_by(name: blockchain_name) do
      {:ok, %Blockchain{id: blockchain_id}} -> Map.put(params, :blockchain_id, blockchain_id)
      {:error, _error} -> params
    end
  end

  defp fetch_blockchain_id(params), do: params

  @spec handle_response(
          {:ok, asset :: Asset.t()} | {:error, error :: error()},
          conn :: conn(),
          status :: status(),
          template :: template()
        ) :: conn() | {:error, error()}
  defp handle_response({:error, error}, _conn, _status, _template), do: {:error, error}

  defp handle_response({:ok, %Asset{code: code} = asset}, conn, :created, template) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.assets_path(conn, :show, code))
    |> render(template, asset: asset)
  end

  defp handle_response({:ok, asset}, conn, status, template) do
    conn
    |> put_status(status)
    |> render(template, asset: asset)
  end
end
