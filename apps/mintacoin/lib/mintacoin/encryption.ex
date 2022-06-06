defmodule Mintacoin.Encryption do
  @moduledoc """
  This module provides the boundary for the Encryption's operations.
  """

  @behaviour Mintacoin.Encryption.Spec

  alias Mintacoin.Encryption.Default

  @impl true
  def generate_secret(opts \\ []), do: impl().generate_secret(opts)

  @impl true
  def encrypt(payload, key), do: impl().encrypt(payload, key)

  @impl true
  def decrypt(ciphertext, key), do: impl().decrypt(ciphertext, key)

  @impl true
  def one_time_token(opts \\ []), do: impl().one_time_token(opts)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:encryption, :impl, Default)
end
