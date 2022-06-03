defmodule Mintacoin.Mnemonic.Spec do
  @moduledoc """
  Specifies the functions available for the Mnemonic
  """

  @type entropy :: String.t()
  @type seed_words :: String.t()
  @type error :: :mnemonic_seed_words_error | :mnemonic_entropy_error

  @callback random_entropy_and_mnemonic :: {:ok, {entropy(), seed_words()}}

  @callback to_entropy(seed_words()) :: {:ok, entropy()} | {:error, error()}

  @callback from_entropy(entropy()) :: {:ok, seed_words()} | {:error, error()}
end
