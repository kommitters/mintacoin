defmodule Mintacoin.Keypair do
  @moduledoc """
  This module provides the boundary for the Keypair's operations.
  """

  @behaviour Mintacoin.Keypair.Spec

  alias Mintacoin.Keypair.Default

  @impl true
  def random, do: impl().random()

  @impl true
  def from_secret_key(secret_key), do: impl().from_secret_key(secret_key)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:keypair, :impl, Default)
end
