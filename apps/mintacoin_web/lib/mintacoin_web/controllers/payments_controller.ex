defmodule MintacoinWeb.PaymentsController do
  use MintacoinWeb, :controller

  alias Ecto.Changeset
  alias MintacoinWeb.Utils.RequestParams
  alias Mintacoin.{Payment, Payments}

  @type params :: map()
  @type conn :: Plug.Conn.t()
  @type status :: :ok | :created
  @type template :: String.t()
  @type error :: :not_found | Changeset.t()

  action_fallback MintacoinWeb.FallbackController

  @spec create(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def create(conn, params) do
    params
    |> RequestParams.fetch_allowed(:payments)
    |> Payments.create()
    |> handle_response(conn, :created, "payment.json")
  end

  @spec show(conn :: conn(), params :: params()) :: conn() | {:error, error()}
  def show(conn, %{"id" => id}) do
    id
    |> Payments.retrieve()
    |> handle_response(conn, :ok, "payment.json")
  end

  @spec handle_response(
          {:ok, payment :: Payment.t()} | {:error, error :: error()},
          conn :: conn(),
          status :: status(),
          template :: template()
        ) :: conn() | {:error, error()}
  defp handle_response({:error, error}, _conn, _status, _template), do: {:error, error}

  defp handle_response({:ok, payment}, conn, status, template) do
    conn
    |> put_status(status)
    |> render(template, payment: payment)
  end
end
