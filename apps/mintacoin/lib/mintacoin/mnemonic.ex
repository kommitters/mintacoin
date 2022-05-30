defmodule Mintacoin.Mnemonic do
  @moduledoc """
  This module provides the boundary for the Mnemonic's operations.
  """

  @behaviour Mintacoin.Mnemonic.Spec

  alias Mintacoin.Mnemonic.Default

  @impl true
  def random_entropy_and_mnemonic, do: impl().random_entropy_and_mnemonic()

  @impl true
  def to_entropy(seed_words), do: impl().to_entropy(seed_words)

  @impl true
  def from_entropy(entropy), do: impl().from_entropy(entropy)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:mnemonic, :impl, Default)
end
