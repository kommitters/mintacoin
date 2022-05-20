defmodule Mintacoin.Encrypter do
  @moduledoc """
  This module provides the boundary for the Encrypter's operations.
  """

  @behaviour Mintacoin.Encrypter.Spec

  @impl true
  def generate_secret, do: impl().generate_secret()

  @impl true
  def encrypt(val, key), do: impl().encrypt(val, key)

  @impl true
  def decrypt(ciphertext, key), do: impl().decrypt(ciphertext, key)

  @spec impl() :: atom()
  defp impl, do: Application.get_env(:encrypter, :impl, Mintacoin.Encrypter.Default)
end
