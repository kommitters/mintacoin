defmodule MintacoinWeb.Plugs.Authenticate do
  @moduledoc """
  Validate authorization token in request header.
  """

  @behaviour Plug

  import Plug.Conn, only: [halt: 1, put_status: 2, get_req_header: 2]
  import Phoenix.Controller, only: [put_view: 2, render: 2]

  alias MintacoinWeb.ErrorView
  alias Mintacoin.Minters

  @auth_header "authorization"

  @type conn :: Plug.Conn.t()

  @impl true
  def init(default), do: default

  @impl true
  def call(conn, _default) do
    with ["Bearer " <> api_key] <- get_req_header(conn, @auth_header),
         true <- Minters.is_authorized?(api_key) do
      conn
    else
      _error -> unauthorized_response(conn)
    end
  end

  @spec unauthorized_response(conn :: conn()) :: conn()
  defp unauthorized_response(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render(:"401")
    |> halt()
  end
end
