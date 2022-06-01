defmodule Mintacoin.Mnemonic.Default do
  @moduledoc """
  This module provides a default implementation o for the Mnemonic
  module using :crypto erlang's module and Bip39's dependency.1
  """

  @behaviour Mintacoin.Mnemonic.Spec

  @block_size 16
  @language :english

  @impl true
  def random_entropy_and_mnemonic do
    raw_entropy = :crypto.strong_rand_bytes(@block_size)
    entropy = Base.encode64(raw_entropy, padding: false)

    @language
    |> Bip39.get_words()
    |> (&Bip39.entropy_to_mnemonic(raw_entropy, &1)).()
    |> Enum.join(" ")
    |> (&{:ok, {entropy, &1}}).()
  end

  @impl true
  def to_entropy(seed_words) do
    mnemonic_list = String.split(seed_words)

    @language
    |> Bip39.get_words()
    |> (&Bip39.mnemonic_to_entropy(mnemonic_list, &1)).()
    |> Base.encode64(padding: false)
    |> (&{:ok, &1}).()
  rescue
    _error -> {:error, :mnemonic_seed_words_error}
  end

  @impl true
  def from_entropy(entropy) do
    {:ok, raw_entropy} = Base.decode64(entropy, padding: false)

    @language
    |> Bip39.get_words()
    |> (&Bip39.entropy_to_mnemonic(raw_entropy, &1)).()
    |> Enum.join(" ")
    |> (&{:ok, &1}).()
  rescue
    _error -> {:error, :mnemonic_entropy_error}
  end
end
