defmodule Mintacoin.Keypair.Default do
  @moduledoc """
  This module provides a default implementation o for the Keypair
  module using :crypto erlang's module and generating ddsa keys.
  """

  @behaviour Mintacoin.Keypair.Spec

  @type public_key :: String.t()
  @type secret_key :: String.t()
  @type keypair :: {public_key, secret_key}

  @key_type :eddsa
  @edwards_curve_ed :ed25519

  @impl true
  def random do
    @key_type
    |> :crypto.generate_key(@edwards_curve_ed)
    |> encode_keypair()
  end

  @impl true
  def from_secret_key(secret_key) do
    {:ok, secret_key} = Base.decode64(secret_key, padding: false)

    @key_type
    |> :crypto.generate_key(@edwards_curve_ed, secret_key)
    |> encode_keypair()
  rescue
    _error -> {:error, :secret_key_error}
  end

  @spec encode_keypair(keypair) :: {:ok, keypair}
  defp encode_keypair({public_key, secret_key}) do
    encoded_public_key = Base.hex_encode32(public_key, padding: false)
    encoded_secret_key = Base.encode64(secret_key, padding: false)

    {:ok, {encoded_public_key, encoded_secret_key}}
  end
end
