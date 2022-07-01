defmodule Mintacoin.Crypto do
  @moduledoc """
  This module provides the boundary for the Crypto's transactions.
  """

  @behaviour Mintacoin.Crypto.Spec

  alias Mintacoin.Crypto.Stellar

  @impl true
  def create_account(params), do: impl().create_account(params)

  @impl true
  def create_asset(params), do: impl().create_asset(params)

  @impl true
  def authorize_asset(params), do: impl().authorize_asset(params)

  @impl true
  def process_payment(params), do: impl().process_payment(params)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:crypto, :impl, Stellar)
end
