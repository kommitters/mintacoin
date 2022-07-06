defmodule MintacoinWeb.Plugs.ValidateMinterSignature do
  @moduledoc """
  Validate signature in the minter of the request.
  """

  @behaviour Plug

  import Plug.Conn, only: [halt: 1, put_status: 2]
  import Phoenix.Controller, only: [put_view: 2, render: 2]

  alias MintacoinWeb.ErrorView
  alias Mintacoin.{Account, Accounts, Keypair}

  @type conn :: Plug.Conn.t()

  @impl true
  def init(default), do: default

  @impl true
  def call(
        %{params: %{"signature" => signature}, assigns: %{"minter" => %{email: email}}} = conn,
        _default
      ) do
    with {:ok, {derived_key, _encoded_secret_key}} <- Keypair.from_secret_key(signature),
         {:ok, %Account{derived_key: ^derived_key}} <-
           Accounts.retrieve_by(email: email, status: :active) do
      conn
    else
      _error -> unauthorized_response(conn)
    end
  end

  def call(conn, _default), do: unauthorized_response(conn)

  @spec unauthorized_response(conn :: conn()) :: conn()
  defp unauthorized_response(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render(:"401")
    |> halt()
  end
end
