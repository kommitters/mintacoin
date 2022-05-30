defmodule Mintacoin.Mnemonic.DefaultTest do
  @moduledoc """
  This modules defines the test cases of the `Mnemonic.Default` module.
  """

  use Mintacoin.DataCase

  alias Mintacoin.Mnemonic

  setup do
    %{
      entropy: "cOyBaqug5GtdZ2rqMOAqdg",
      seed_words: [
        "ill",
        "goat",
        "follow",
        "firm",
        "atom",
        "cup",
        "intact",
        "unhappy",
        "tuition",
        "mandate",
        "appear",
        "uncover"
      ]
    }
  end

  describe "random_entropy_and_mnemonic/0" do
    test "returns a random set of entropy and seed words" do
      {:ok, {entropy, seed_words}} = Mnemonic.random_entropy_and_mnemonic()

      refute is_nil(entropy)
      12 = Enum.count(seed_words)
    end
  end

  describe "to_entropy/1" do
    test "returns the pair entropy to the mnemonic", %{
      entropy: spec_entropy,
      seed_words: seed_words
    } do
      {:ok, ^spec_entropy} = Mnemonic.to_entropy(seed_words)
    end

    test "show error with invalid seed words" do
      {:error, :mnemonic_seed_words_error} = Mnemonic.to_entropy("INVALID ENTRY")
    end
  end

  describe "from_entropy/1" do
    test "returns the mnemonic pair to the given entropy", %{
      entropy: entropy,
      seed_words: seed_words
    } do
      {:ok, ^seed_words} = Mnemonic.from_entropy(entropy)
    end

    test "show error with invalid entropy" do
      {:error, :mnemonic_entropy_error} = Mnemonic.from_entropy("INVALID ENTRY")
    end
  end
end
