defmodule MintacoinWeb.AccountsController do
  use MintacoinWeb, :controller

  alias Mintacoin.Accounts
  alias Mintacoin.Account

  @type params :: map()
  @type conn :: Plug.Conn.t()
  @type error :: :not_found | :bad_request | Ecto.Changeset.t()

  @allowed_params ~w(email name)

  action_fallback MintacoinWeb.FallbackController

  @spec create(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def create(conn, params) do
    allowed_params = fetch_allowed_params(params)

    case Accounts.create(allowed_params) do
      {:ok, account} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.accounts_path(conn, :show, account))
        |> render("account.json", account: account)

      {:error, error} ->
        {:error, error}
    end
  end

  @spec show(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def show(conn, %{"address" => address}) do
    case Accounts.retrieve(address) do
      {:ok, %Account{} = account} ->
        conn
        |> put_status(:ok)
        |> render("account.json", account: account)

      {:error, :not_found} ->
        {:error, :not_found}

      {:error, :bad_argument} ->
        {:error, :bad_request}
    end
  end

  @spec update(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def update(conn, %{"address" => address} = params) do
    with allowed_params when allowed_params != %{} <- fetch_allowed_params(params),
         {:ok, account} <- Accounts.update(address, allowed_params) do
      conn
      |> put_status(:ok)
      |> render("account.json", account: account)
    else
      {:error, :not_found} -> {:error, :not_found}
      _error -> {:error, :bad_request}
    end
  end

  @spec delete(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def delete(conn, %{"address" => address}) do
    case Accounts.delete(address) do
      {:ok, _account} -> send_resp(conn, :no_content, "")
      {:error, :not_found} -> {:error, :not_found}
      {:error, :bad_argument} -> {:error, :bad_request}
    end
  end

  @spec recover(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def recover(conn, %{"address" => address, "seed_words" => seed_words}) do
    case Accounts.recover_signature(address, seed_words) do
      {:ok, signature} -> render(conn, "signature.json", signature: signature)
      {:error, :not_found} -> {:error, :not_found}
      {:error, :bad_argument} -> {:error, :bad_request}
    end
  end

  @spec fetch_allowed_params(params :: params()) :: params()
  defp fetch_allowed_params(params) do
    params
    |> Map.take(@allowed_params)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      key
      |> String.to_existing_atom()
      |> (&Map.put(acc, &1, value)).()
    end)
  end
end
