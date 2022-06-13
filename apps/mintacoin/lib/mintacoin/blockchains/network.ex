defmodule Mintacoin.Blockchains.Network do
  @moduledoc """
  This module provides the boundary for the Blockchain Network.
  """

  @behaviour Mintacoin.Blockchains.Network.Spec

  alias Mintacoin.Blockchains.Network.Stellar

  @impl true
  def name, do: impl().name()

  @impl true
  def struct, do: impl().struct()

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:network, :impl, Stellar)
end
