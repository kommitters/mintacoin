defmodule MintacoinWeb.AccountsController do
  use MintacoinWeb, :controller

  alias Ecto.Changeset
  alias MintacoinWeb.Utils.RequestParams
  alias Mintacoin.{Account, Accounts}

  @type params :: map()
  @type conn :: Plug.Conn.t()
  @type status :: :ok | :created
  @type template :: String.t()
  @type response :: Account.t() | String.t()
  @type error :: :not_found | :bad_request | Changeset.t()

  action_fallback MintacoinWeb.FallbackController

  @spec create(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def create(conn, params) do
    params
    |> RequestParams.fetch_allowed(:accounts)
    |> Accounts.create()
    |> handle_response(conn, :created, "account.json")
  end

  @spec show(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def show(conn, %{"address" => address}) do
    address
    |> Accounts.retrieve()
    |> handle_response(conn, :ok, "account.json")
  end

  @spec update(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def update(conn, %{"address" => address} = params) do
    params
    |> RequestParams.fetch_allowed(:accounts)
    |> (&Accounts.update(address, &1)).()
    |> handle_response(conn, :ok, "account.json")
  end

  @spec delete(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def delete(conn, %{"address" => address}) do
    address
    |> Accounts.delete()
    |> handle_response(conn, :ok, "account.json")
  end

  @spec recover(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def recover(conn, %{"address" => address, "seed_words" => seed_words}) do
    address
    |> Accounts.recover_signature(seed_words)
    |> handle_response(conn, :ok, "signature.json")
  end

  @spec handle_response(
          {:ok, response :: response()} | {:error, error :: error()},
          conn :: conn(),
          status :: status(),
          template :: template()
        ) :: conn() | {:error, error()}
  defp handle_response({:error, :not_found}, _conn, _status, _template), do: {:error, :not_found}

  defp handle_response({:error, :bad_argument}, _conn, _status, _template),
    do: {:error, :bad_request}

  defp handle_response({:error, %Changeset{} = changeset}, _conn, _status, _template),
    do: {:error, changeset}

  defp handle_response({:ok, %Account{address: address} = resource}, conn, :created, template) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.accounts_path(conn, :show, address))
    |> render(template, resource: resource)
  end

  defp handle_response({:ok, resource}, conn, status, template) do
    conn
    |> put_status(status)
    |> render(template, resource: resource)
  end
end
